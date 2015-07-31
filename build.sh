#!/bin/sh

set -e

# Switching Gemfile
set_gemfile(){
  echo "Switching Gemfile..."
  export BUNDLE_GEMFILE="`pwd`/Gemfile"
}

# Target postgres. Override with: `DB=sqlite bash build.sh`
export DB=${DB:-postgres}

# Gesmew defaults
echo "Setup Gesmew defaults and creating test application..."
bundle check || bundle update --quiet
bundle exec rake test_app

# Gesmew API
echo "**************************************"
echo "* Setup Gesmew API and running RSpec..."
echo "**************************************"
cd api; set_gemfile; bundle update --quiet; bundle exec rspec spec

# Gesmew Backend
echo "******************************************"
echo "* Setup Gesmew Backend and running RSpec..."
echo "******************************************"
cd ../backend; set_gemfile; bundle update --quiet; bundle exec rspec spec

# Gesmew Core
echo "***************************************"
echo "* Setup Gesmew Core and running RSpec..."
echo "***************************************"
cd ../core; set_gemfile; bundle update --quiet; bundle exec rspec spec

# Gesmew Frontend
echo "*******************************************"
echo "* Setup Gesmew Frontend and running RSpec..."
echo "*******************************************"
cd ../frontend; set_gemfile; bundle update --quiet; bundle exec rspec spec

# Gesmew Sample
echo "*****************************************"
echo "* Setup Gesmew Sample and running RSpec..."
echo "*****************************************"
cd ../sample; set_gemfile; bundle update --quiet; bundle exec rspec spec
