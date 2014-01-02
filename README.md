## hiera-postgresql-backend

Alternate PostgreSQL backend for Hiera

This is a PostgreSQL backend for Hiera inspired by [hiera-mysql-backend](https://github.com/Telmo/hiera-mysql-backend). 


### What goes into the sql files.

The poorly named sql files are really yaml files where the key is the lookup key and the value is the SQL statement (it accepts interpolation)

Lets assume your _datadir_ is `/etc/puppet/hieradata/` and your hierarchy for hiera just have a common. hiera-postgresql-backend would look for /etc/puppet/hieradata/common.sql the common.sql would look like:

```yaml
---
applications: SELECT * FROM applications WHERE host='%{fqdn}';
coats: SELECT cut,name,type FROM coats WHERE color='brown';
```

running `hiera applications` would run the query against the configured database.


### Using

`gem install hiera-postgres-backend`


### Configuring Hiera

Hiera configuration is pretty simple

```yaml
---
:backends:
  - yaml
  - postgres

:yaml:
  :datadir: /etc/puppet/hieradata

:postgres:
  :datadir: /etc/puppet/hieradata
  :host: hostname
  :user: username
  :pass: password
  :database: database

:hierarchy:
  - "%{::clientcert}"
  - "%{::custom_location}"
  - common

:logger: console
```

## Known issues

1. It always return an Array of hashes regardless of the number of items returned. (I did this on purpose because it is what I needed but I may be persuaded to do otherwise)
2. This README is poorly written.


## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
