require 'thor'
require 'thor/group'

case ARGV.first
  when 'version', '-v', '--version'
    puts Gem.loaded_specs['gesmew_cmd'].version
  when 'extension'
    ARGV.shift
    require 'gesmew_cmd/extension'
    GesmewCmd::Extension.start
  else
    ARGV.shift
    require 'gesmew_cmd/installer'
    GesmewCmd::Installer.start
end
