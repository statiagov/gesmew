# encoding: UTF-8
version = File.read(File.expand_path("../../GESMEW_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'gesmew_backend'
  s.version     = version
  s.summary     = 'backend functionality for the Gesmew project.'
  s.description = 'Required dependency for Gesmew'

  s.author      = 'Michail Gumbs'
  s.email       = 'mjgumbs.200@gmail.com'
  s.homepage    = 'https://'
  s.license     = %q{BSD-3}
  s.rubyforge_project = 'gesmew_backend'

  s.files        = Dir['LICENSE', 'README.md', 'app/**/*', 'config/**/*', 'lib/**/*', 'db/**/*', 'vendor/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'gesmew_api', version
  s.add_dependency 'gesmew_core', version

  s.add_dependency 'bootstrap-sass',  '~> 3.3.5.1'
  s.add_dependency 'jquery-rails',    '~> 4.0.3'
  s.add_dependency 'jquery-ui-rails', '~> 5.0.0'
  s.add_dependency 'select2-rails',   '3.5.9.1' # 3.5.9.2 breaks several specs
  s.add_dependency 'sprockets-rails', '~> 2.2'
end
