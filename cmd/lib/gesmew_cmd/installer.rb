require 'rbconfig'
require 'active_support/core_ext/string'

module GesmewCmd

  class Installer < Thor::Group
    include Thor::Actions

    desc 'Creates a new rails project with a gesmew store'
    argument :app_path, :type => :string, :desc => 'rails app_path', :default => '.'

    class_option :auto_accept, :type => :boolean, :aliases => '-A',
                               :desc => 'Answer yes to all prompts'

    class_option :skip_install_data, :type => :boolean, :default => false,
                 :desc => 'Skip running migrations and loading seed and sample data'

    class_option :version, :type => :string, :desc => 'Gesmew Version to use'

    class_option :edge, :type => :boolean

    class_option :path, :type => :string, :desc => 'Gesmew gem path'
    class_option :git, :type => :string, :desc => 'Gesmew gem git url'
    class_option :ref, :type => :string, :desc => 'Gesmew gem git ref'
    class_option :branch, :type => :string, :desc => 'Gesmew gem git branch'
    class_option :tag, :type => :string, :desc => 'Gesmew gem git tag'

    def verify_rails
      unless rails_project?
        say "#{@app_path} is not a rails project."
        exit 1
      end
    end

    def verify_image_magick
      unless image_magick_installed?
        say "Image magick must be installed."
        exit 1
      end
    end

    def prepare_options
      @gesmew_gem_options = {}

      if options[:edge] || options[:branch]
        @gesmew_gem_options[:git] = 'https://github.com/gesmew/gesmew.git'
      elsif options[:path]
        @gesmew_gem_options[:path] = options[:path]
      elsif options[:git]
        @gesmew_gem_options[:git] = options[:git]
        @gesmew_gem_options[:ref] = options[:ref] if options[:ref]
        @gesmew_gem_options[:tag] = options[:tag] if options[:tag]
      elsif options[:version]
        @gesmew_gem_options[:version] = options[:version]
      else
        version = Gem.loaded_specs['gesmew_cmd'].version
        @gesmew_gem_options[:version] = version.to_s
      end

      @gesmew_gem_options[:branch] = options[:branch] if options[:branch]
    end

    def ask_questions
      @install_default_gateways = ask_with_default('Would you like to install the default gateways? (Recommended)')
      @install_default_auth = ask_with_default('Would you like to install the default authentication system?')

      if @install_default_auth
        @user_class = "Gesmew::User"
      else
        @user_class = ask("What is the name of the class representing users within your application? [User]")
        if @user_class.blank?
          @user_class = "User"
        end
      end

      if options[:skip_install_data]
        @run_migrations = false
        @load_seed_data = false
        @load_sample_data = false
      else
        @run_migrations = ask_with_default('Would you like to run the migrations?')
        if @run_migrations
          @load_seed_data = ask_with_default('Would you like to load the seed data?')
          @load_sample_data = ask_with_default('Would you like to load the sample data?')
        else
          @load_seed_data = false
          @load_sample_data = false
        end
      end
    end

    def add_gems
      inside @app_path do

        gem :gesmew, @gesmew_gem_options

        if @install_default_gateways && @gesmew_gem_options[:branch]
          gem :gesmew_gateway, github: 'gesmew/gesmew_gateway', branch: @gesmew_gem_options[:branch]
        elsif @install_default_gateways
          gem :gesmew_gateway, github: 'gesmew/gesmew_gateway'
        end

        if @install_default_auth && @gesmew_gem_options[:branch]
          gem :gesmew_auth_devise, github: 'gesmew/gesmew_auth_devise', branch: @gesmew_gem_options[:branch]
        elsif @install_default_auth
          gem :gesmew_auth_devise, github: 'gesmew/gesmew_auth_devise'
        end

        run 'bundle install', :capture => true
      end
    end

    def initialize_gesmew
      gesmew_options = []
      gesmew_options << "--migrate=#{@run_migrations}"
      gesmew_options << "--seed=#{@load_seed_data}"
      gesmew_options << "--sample=#{@load_sample_data}"
      gesmew_options << "--user_class=#{@user_class}"
      gesmew_options << "--auto_accept" if options[:auto_accept]

      inside @app_path do
        run "rails generate gesmew:install #{gesmew_options.join(' ')}", :verbose => false
      end
    end

    private

      def gem(name, gem_options={})
        say_status :gemfile, name
        parts = ["'#{name}'"]
        parts << ["'#{gem_options.delete(:version)}'"] if gem_options[:version]
        gem_options.each { |key, value| parts << "#{key}: '#{value}'" }
        append_file 'Gemfile', "\ngem #{parts.join(', ')}", :verbose => false
      end

      def ask_with_default(message, default = 'yes')
        return true if options[:auto_accept]

        valid = false
        until valid
          response = ask "#{message} (yes/no) [#{default}]"
          response = default if response.empty?
          valid = (response  =~ /\Ay(?:es)?|no?\Z/i)
        end
        response.downcase[0] == ?y
      end

      def ask_string(message, default, valid_regex = /\w/)
        return default if options[:auto_accept]
        valid = false
        until valid
          response = ask "#{message} [#{default}]"
          response = default if response.empty?
          valid = (valid_regex === response)
        end
        response
      end

      def create_rails_app
        say :create, @app_path

        rails_cmd = "rails new #{@app_path} --skip-bundle"
        rails_cmd << " -m #{options[:template]}" if options[:template]
        rails_cmd << " -d #{options[:database]}" if options[:database]
        run(rails_cmd)
      end

      def rails_project?
        File.exists? File.join(@app_path, 'bin', 'rails')
      end

      def linux?
        /linux/i === RbConfig::CONFIG['host_os']
      end

      def mac?
        /darwin/i === RbConfig::CONFIG['host_os']
      end

      def windows?
        %r{msdos|mswin|djgpp|mingw} === RbConfig::CONFIG['host_os']
      end

      def image_magick_installed?
        cmd = 'identify -version'
        if RUBY_PLATFORM =~ /mingw|mswin/ #windows
          cmd += " >nul"
        else
          cmd += " >/dev/null"
        end
        # true if command executed succesfully
        # false for non zero exit status
        # nil if command execution fails
        system(cmd)
      end
  end
end
