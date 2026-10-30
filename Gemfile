source "https://rubygems.org"

gem 'sinatra'
gem 'sinatra-contrib'
gem 'ruby-audio'
gem 'puma'
gem 'haml'
gem 'flacinfo-rb'
gem "lame", "0.0.5"
gem "yaml"

group :staging, :production do
  gem "rack-ssl-enforcer"
end

group :development do
  gem "capistrano", "~> 3.14", require: false
end
