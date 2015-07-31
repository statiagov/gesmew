module GesmewCmd
  class Version < Thor::Group
    include Thor::Actions

		desc 'display gesmew_cmd version'

		def cmd_version
			puts Gem.loaded_specs['gesmew_cmd'].version
		end

  end
end
