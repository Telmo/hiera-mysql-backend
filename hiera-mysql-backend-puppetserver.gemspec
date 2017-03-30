# -*- encoding: utf-8 -*-

Gem::Specification.new do |gem|
  gem.name          = "hiera-mysql-backend-jruby"
  gem.version       = "0.0.9"
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
  gem.add_dependency('jdbc-mysql')
  gem.add_development_dependency('rake')
end
