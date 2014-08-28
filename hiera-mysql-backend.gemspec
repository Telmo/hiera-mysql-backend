# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "hiera-mysql-backend"
  gem.version       = "0.0.6"
  gem.authors       = ["Telmo"]
  gem.email         = ["telmox@gmail.com"]
  gem.description   = %q{Alternative MySQL backend for hiera}
  gem.summary       = %q{Alternative MySQL backend for hiera}
  gem.homepage      = "https://github.com/Telmo/hiera-mysql-backend"
  gem.license       = "MIT"

  gem.files         = `git ls-files`.split($/)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.require_paths = ["lib"]
  gem.add_dependency('mysql2')
  gem.add_dependency('hiera')
  gem.add_development_dependency('rake')
end
