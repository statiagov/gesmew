# encoding: UTF-8
version = File.read(File.expand_path('../GESMEW_VERSION',__FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'gesmew'
  s.version     = version
  s.summary     = 'Gesmew application'
  s.description = 'Gesmew website'

  s.files        = Dir['README.md', 'lib/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.author       = 'Michail Gumbs'
  s.email        = 'mjgumbs.200@gmail.com'
  s.homepage     = 'http://'
  s.license      = %q{BSD-3}

  s.add_dependency 'gesmew_core', version
  s.add_dependency 'gesmew_api', version
  s.add_dependency 'gesmew_backend', version
  s.add_dependency 'gesmew_frontend', version
  s.add_dependency 'gesmew_sample', version
  s.add_dependency 'gesmew_cmd', version
end
