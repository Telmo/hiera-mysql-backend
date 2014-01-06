class Hiera
  module Backend
    class Postgres_backend

      def initialize(cache=nil)
        begin
          require 'pg'
        rescue LoadError
          require 'rubygems'
          require 'pg'
        end

        @cache = cache || Filecache.new

        Hiera.debug("Hiera PostgreSQL initialized")
      end

      def lookup(key, scope, order_override, resolution_type)
        # default answer is set to nil otherwise the lookup ends up returning
        # an Array of nils and causing a Puppet::Parser::AST::Resource failed with error ArgumentError
        # for any other lookup because their default value is overwriten by [nil,nil,nil,nil]
        # so hiera('myvalue', 'test1') returns [nil,nil,nil,nil]
      	answer = nil

        Hiera.debug("looking up #{key} in PostgreSQL Backend")
        Hiera.debug("resolution type is #{resolution_type}")

        Backend.datasources(scope, order_override) do |source|
          Hiera.debug("Looking for data source #{source}")
          sqlfile = Backend.datafile(:postgres, scope, source, "sql") || next

          next unless File.exist?(sqlfile)
          data = @cache.read(sqlfile, Hash, {}) do |datafile|
            YAML.load(datafile)
          end

          Hiera.debug("data #{data.inspect}")
          next if data.empty?
          next unless data.include?(key)

          Hiera.debug("Found #{key} in #{source}")

          new_answer = Backend.parse_answer(data[key], scope)
          case resolution_type
          when :array
            raise Exception, "Hiera type mismatch: expected Array and got #{new_answer.class}" unless new_answer.kind_of? Array or new_answer.kind_of? String
            answer ||= []
            answer << query(new_answer)
          when :hash
            raise Exception, "Hiera type mismatch: expected Hash and got #{new_answer.class}" unless new_answer.kind_of? Hash
            answer ||= {}
            answer = Backend.merge_answer(query(new_answer),answer)
          else
            answer = query(new_answer)
            break
          end

        end
          return answer
      end


      def query(query)
        Hiera.debug("Executing SQL Query: #{query}")

        data=nil
        pg_host = Config[:postgres][:host]
        pg_user = Config[:postgres][:user]
        pg_pass = Config[:postgres][:pass]
        pg_database = Config[:postgres][:database]
        client = PG::Connection.new(:host     => pg_host, 
                                    :user     => pg_user, 
                                    :password => pg_pass, 
                                    :dbname   => pg_database)
        begin
          data = client.exec(query).to_a
          Hiera.debug("PostgreSQL Query returned #{data.size} rows")
        rescue => e
          Hiera.debug e.message
          data = nil
        ensure
          client.close
        end

        return data

      end
    end
  end
end
