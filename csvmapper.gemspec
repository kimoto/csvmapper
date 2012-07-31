# -*- encoding: utf-8 -*-
require File.expand_path('../lib/csvmapper/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["kimoto"]
  gem.email         = ["sub+peerler@gmail.com"]
  gem.description   = %q{CSV to Ruby class mapper}
  gem.summary       = %q{CSV to Ruby class mapper}
  gem.homepage      = ""

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "csvmapper"
  gem.require_paths = ["lib"]
  gem.version       = CSVMapper::VERSION
end
