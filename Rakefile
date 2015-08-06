require 'rake'
require 'rubygems/package_task'
require 'thor/group'
begin
  require 'gesmew/testing_support/common_rake'
rescue LoadError
  raise "Could not find gesmew/testing_support/common_rake. You need to run this command using Bundler."
  exit
end

spec = eval(File.read('gesmew.gemspec'))
Gem::PackageTask.new(spec) do |pkg|
  pkg.gem_spec = spec
end

task default: :test

desc "Runs all tests in all Gesmew engines"
task :test do
  Rake::Task['test_app'].invoke
  %w(api backend core frontend sample).each do |gem_name|
    Dir.chdir("#{File.dirname(__FILE__)}/#{gem_name}") do
      system("rspec") or exit!(1)
    end
  end
end

desc "Generates a dummy app for testing for every Gesmew engine"
task :test_app do
  require File.expand_path('../core/lib/generators/gesmew/install/install_generator', __FILE__)
  %w(api backend core frontend sample).each do |engine|
    ENV['LIB_NAME'] = File.join('gesmew', engine)
    ENV['DUMMY_PATH'] = File.expand_path("../#{engine}/spec/dummy", __FILE__)
    Rake::Task['common:test_app'].execute
  end
end

desc "clean the whole repository by removing all the generated files"
task :clean do
  puts "Deleting sandbox..."
  FileUtils.rm_rf("sandbox")
  puts "Deleting pkg directory.."
  FileUtils.rm_rf("pkg")

  %w(api backend cmd core frontend).each do |gem_name|
    puts "Cleaning #{gem_name}:"
    puts "  Deleting #{gem_name}/Gemfile"
    FileUtils.rm_f("#{gem_name}/Gemfile")
    puts "  Deleting #{gem_name}/pkg"
    FileUtils.rm_rf("#{gem_name}/pkg")
    puts "  Deleting #{gem_name}'s dummy application"
    Dir.chdir("#{gem_name}/spec") do
      FileUtils.rm_rf("dummy")
    end
  end
end

namespace :gem do
  desc "run rake gem for all gems"
  task :build do
    %w(core api backend frontend sample cmd).each do |gem_name|
      puts "########################### #{gem_name} #########################"
      puts "Deleting #{gem_name}/pkg"
      FileUtils.rm_rf("#{gem_name}/pkg")
      cmd = "cd #{gem_name} && bundle exec rake gem"; puts cmd; system cmd
    end
    puts "Deleting pkg directory"
    FileUtils.rm_rf("pkg")
    cmd = "bundle exec rake gem"; puts cmd; system cmd
  end
end

namespace :gem do
  desc "run gem install for all gems"
  task :install do
    version = File.read(File.expand_path("../Gesmew_VERSION", __FILE__)).strip

    %w(core api backend frontend sample cmd).each do |gem_name|
      puts "########################### #{gem_name} #########################"
      puts "Deleting #{gem_name}/pkg"
      FileUtils.rm_rf("#{gem_name}/pkg")
      cmd = "cd #{gem_name} && bundle exec rake gem"; puts cmd; system cmd
      cmd = "cd #{gem_name}/pkg && gem install gesmew_#{gem_name}-#{version}.gem"; puts cmd; system cmd
    end
    puts "Deleting pkg directory"
    FileUtils.rm_rf("pkg")
    cmd = "bundle exec rake gem"; puts cmd; system cmd
    cmd = "gem install pkg/gesmew-#{version}.gem"; puts cmd; system cmd
  end
end

namespace :gem do
  desc "Release all gems to gemcutter. Package gesmew components, then push gesmew"
  task :release do
    version = File.read(File.expand_path("../Gesmew_VERSION", __FILE__)).strip

    %w(core api backend frontend sample cmd).each do |gem_name|
      puts "########################### #{gem_name} #########################"
      cmd = "cd #{gem_name}/pkg && gem push gesmew_#{gem_name}-#{version}.gem"; puts cmd; system cmd
    end
    cmd = "gem push pkg/gesmew-#{version}.gem"; puts cmd; system cmd
  end
end

desc "Creates a sandbox application for simulating the Gesmew code in a deployed Rails app"
task :sandbox do
  Bundler.with_clean_env do
    exec("lib/sandbox.sh")
  end
end
