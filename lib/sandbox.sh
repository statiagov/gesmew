#!/bin/sh
# Used in the sandbox rake task in Rakefile

rm -rf ./sandbox
bundle exec rails new sandbox --skip-bundle
if [ ! -d "sandbox" ]; then
  echo 'sandbox rails application failed'
  exit 1
fi

cd ./sandbox

cat <<RUBY >> Gemfile
gem 'gesmew', path: '..'
gem 'gesmew_auth_devise', github: 'gesmew/gesmew_auth_devise', branch: 'master'

group :test, :development do
  gem 'bullet'
  gem 'pry-byebug'
  gem 'rack-mini-profiler'
end
RUBY

bundle install --gemfile Gemfile
bundle exec rails g gesmew:install --auto-accept --user_class=Gesmew::User --enforce_available_locales=true
bundle exec rails g gesmew:auth:install
