# -*- encoding: utf-8 -*-
version = File.read(File.expand_path("../../GESMEW_VERSION", __FILE__)).strip

Gem::Specification.new do |gem|
  gem.authors       = ["Michail Gumbs"]
  gem.email         = ["mjgumbs.200@gmail.com"]
  gem.description   = %q{Gesmew's API}
  gem.summary       = %q{Gesmew's API}
  gem.homepage      = 'https://'
  gem.license       = %q{BSD-3}

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "gesmew_api"
  gem.require_paths = ["lib"]
  gem.version       = version

  gem.add_dependency 'gesmew_core', version
  gem.add_dependency 'rabl', '~> 0.9.4.pre1'
  gem.add_dependency 'versioncake', '~> 2.3.1'
end
