require 'ffaker'
require 'pathname'
require 'gesmew/sample'

namespace :gesmew_sample do
  desc 'Loads sample data'
  task :load => :environment do
    if ARGV.include?("db:migrate")
      puts %Q{
Please run db:migrate separately from gesmew_sample:load.

Running db:migrate and gesmew_sample:load at the same time has been known to
cause problems where columns may be not available during sample data loading.

Migrations have been run. Please run "rake gesmew_sample:load" by itself now.
      }
      exit(1)
    end

    GesmewSample::Engine.load_samples
  end
end


