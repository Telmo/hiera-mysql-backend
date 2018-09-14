class Hiera
  module Backend
    class Mysql2_backend

      def initialize(cache=nil)
        if defined?(JRUBY_VERSION)
          require 'jdbc/mysql'
          require 'java'
        else
          begin
            require 'mysql2'
          rescue LoadError
            require 'rubygems'
            require 'mysql2'
          end
        end

        @cache = cache || Filecache.new

        Hiera.debug("Hiera MySQL2 initialized")
      end

      def lookup(key, scope, order_override, resolution_type)
        # default answer is set to nil otherwise the lookup ends up returning
        # an Array of nils and causing a Puppet::Parser::AST::Resource failed with error ArgumentError
        # for any other lookup because their default value is overwriten by [nil,nil,nil,nil]
        # so hiera('myvalue', 'test1') returns [nil,nil,nil,nil]
        results = nil

        Hiera.debug("looking up #{key} in MySQL2 Backend")
        Hiera.debug("resolution type is #{resolution_type}")

        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for data source #{source}")
          sqlfile = Backend.datafile(:mysql2, scope, source, "sql") || next

          next unless File.exist?(sqlfile)
          data = @cache.read(sqlfile, Hash, {}) do |datafile|
            YAML.load(datafile)
          end

          mysql_config = data.fetch(:dbconfig, {})
          mysql_host = mysql_config.fetch(:host, nil) || Config[:mysql2][:host] || 'localhost'
          mysql_user = mysql_config.fetch(:user, nil) || Config[:mysql2][:user]
          mysql_pass = mysql_config.fetch(:pass, nil) || Config[:mysql2][:pass]
          mysql_port = mysql_config.fetch(:port, nil) || Config[:mysql2][:port] || '3306'
          mysql_database = mysql_config.fetch(:database, nil) || Config[:mysql2][:database]

          Hiera.debug("data #{data.inspect}")
          next if data.empty?
          next unless data.include?(key)

          connection_hash = {
            :host => Backend.parse_answer(mysql_host, scope),
            :username => Backend.parse_answer(mysql_user, scope),
            :password => Backend.parse_answer(mysql_pass, scope),
            :port => Backend.parse_answer(mysql_port, scope),
            :database => Backend.parse_answer(mysql_database, scope),
            :reconnect => true
          }

          Hiera.debug("Found #{key} in #{source}")

          new_answer = Backend.parse_answer(data[key], scope)
          results = query(connection_hash, new_answer)

        end
        return results
      end


      def query(connection_hash, query)
        Hiera.debug("Executing SQL Query: #{query}")

        data=[]
        mysql_host=connection_hash[:host]
        mysql_user=connection_hash[:username]
        mysql_pass=connection_hash[:password]
        mysql_database=connection_hash[:database]
        mysql_port=connection_hash[:port]

        if defined?(JRUBY_VERSION)
          Jdbc::MySQL.load_driver
          url = "jdbc:mysql://#{mysql_host}:#{mysql_port}/#{mysql_database}"
          props = java.util.Properties.new
          props.set_property :user, mysql_user
          props.set_property :password, mysql_pass

          conn = com.mysql.jdbc.Driver.new.connect(url,props)
          stmt = conn.create_statement

          res = stmt.execute_query(query)
          md = res.getMetaData
          numcols = md.getColumnCount

          Hiera.debug("Mysql Query returned #{numcols} rows")

          while ( res.next ) do
            if numcols < 2
              Hiera.debug("Mysql value : #{res.getString(1)}")
              data << res.getString(1)
            else
              row = {}
              (1..numcols).each do |c|
                row[md.getColumnName(c)] = res.getString(c)
              end
              data << row
            end
          end

        else
          client = Mysql2::Client.new(connection_hash)
          begin
            data = client.query(query).to_a
            Hiera.debug("Mysql Query returned #{data.size} rows")
          rescue => e
            Hiera.debug e.message
            data = nil
          ensure
            client.close
          end
        end

        return data

      end
    end
  end
end
