# encoding: UTF-8
version = File.read(File.expand_path("../../GESMEW_VERSION", __FILE__)).strip

Gem::Specification.new do |s|
  s.platform    = Gem::Platform::RUBY
  s.name        = 'gesmew_sample'
  s.version     = version
  s.summary     = 'Sample data (including images) for use with Gesmew.'
  s.description = 'Required dependency for Gesmew'

  s.author      = 'Michail Gumbs'
  s.email       = 'mjgumbs.200@gmail.com'
  s.homepage    = 'http://'
  s.license     = %q{BSD-3}

  s.files        = Dir['LICENSE', 'README.md', 'lib/**/*', 'db/**/*']
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'gesmew_core', version
end
