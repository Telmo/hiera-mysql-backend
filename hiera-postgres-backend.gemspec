# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "hiera-postgres-backend"
  gem.version       = "0.0.2"
  gem.authors       = ["Adrian"]
  gem.email         = ["adrianlzt@gmail.com"]
  gem.description   = %q{Alternative PostgreSQL backend for hiera}
  gem.summary       = %q{Alternative PostgreSQL backend for hiera}
  gem.homepage      = "https://github.com/adrianlzt/hiera-postgres-backend"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency('pg')
#  gem.add_dependency('hiera')
  gem.add_development_dependency('rake')
end
