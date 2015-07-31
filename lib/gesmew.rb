require 'gesmew_core'
require 'gesmew_api'
require 'gesmew_backend'
require 'gesmew_frontend'
require 'gesmew_sample'

begin
  require 'protected_attributes'
  puts "*" * 75
  puts "[FATAL] Gesmew does not work with the protected_attributes gem installed!"
  puts "You MUST remove this gem from your Gemfile. It is incompatible with Gesmew."
  puts "*" * 75
  exit
rescue LoadError
end
