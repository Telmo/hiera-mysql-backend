## hiera-mysql-backend

Alternate MySQL backend for Hiera

This is a MySQL backend for Hiera inspired by [hiera-mysql](https://github.com/crayfishx/hiera-mysql). Unfortunately no work has been done to that backend for the past 9 months and it was missing a couple of features I needed so I decided to pick up the torch and implement them myself.

### What is different from hiera-mysql

In [hiera-mysql](https://github.com/crayfishx/hiera-mysql) you define the queries in the hiera.yaml file. I felt this was too restricting so instead hiera-mysql-backend uses, poorly named, sql files. This sql files follow the Hiera hierarchy.

[hiera-mysql](https://github.com/crayfishx/hiera-mysql) would also return the last matching query not the first one which I felt it was confusing.

[hiera-mysql](https://github.com/crayfishx/hiera-mysql) used the mysql gem, I am partial to [mysql2](https://github.com/brianmario/mysql2)

Exception handling. hiera-mysql would cause a puppet run to fail if one of the queries was incorrect. For example a fact that you are distributing with a module is needed for the query to return its data but that fact is not available outside the module having a `SELECT * from %{custom_fact}` would make puppet runs fail.

### What goes into the sql files.

The poorly named sql files are really yaml files where the key is the lookup key and the value is the SQL statement (it accepts interpolation)

Lets assume your _datadir_ is `/etc/puppet/hieradata/` and your hierarchy for hiera just have a common. hiera-mysql-backend would look for /etc/puppet/hieradata/common.sql the common.sql would look like:

```yaml
---
applications: SELECT * FROM applications WHERE host='%{fqdn}';
coats: SELECT cut,name,type FROM coats WHERE color='brown';
```

running `hiera applications` would run the query against the configured database.


### Using

`gem install hiera-mysql-backend`


### Configuring Hiera

Hiera configuration is pretty simple

```yaml
---
:backends:
  - yaml
  - mysql2

:yaml:
  :datadir: /etc/puppet/hieradata

:mysql2:
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
