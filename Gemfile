source 'https://rubygems.org'


# Bundle edge Rails instead: gem 'rails', github: 'rails/rails'
gem 'rails', '4.1.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3'
# Use SCSS for stylesheets
gem 'sass-rails', '~> 4.0.3'
# Use Uglifier as compressor for JavaScript assets
gem 'uglifier', '>= 1.3.0'
# Use CoffeeScript for .js.coffee assets and views
gem 'coffee-rails', '~> 4.0.0'
# See https://github.com/sstephenson/execjs#readme for more supported runtimes
# gem 'therubyracer',  platforms: :ruby

# Use jquery as the JavaScript library
gem 'jquery-rails'
# Turbolinks makes following links in your web application faster. Read more: https://github.com/rails/turbolinks
gem 'turbolinks'
# Build JSON APIs with ease. Read more: https://github.com/rails/jbuilder
gem 'jbuilder', '~> 2.0'
# bundle exec rake doc:rails generates the API under doc/api.
gem 'sdoc', '~> 0.4.0',          group: :doc

# Spring speeds up development by keeping your application running in the background. Read more: https://github.com/rails/spring
gem 'spring',        group: :development

# Use ActiveModel has_secure_password
# gem 'bcrypt', '~> 3.1.7'

# Use unicorn as the app server
# gem 'unicorn'

# Use Capistrano for deployment
# gem 'capistrano-rails', group: :development

# Use debugger
# gem 'debugger', group: [:development, :test]

gem 'byebug'

# use one of the following
# libcurl C based http client - faster
# gem 'patron', '0.4.18', :git => 'https://github.com/ddnexus/patron.git'

# pure ruby http client - more compatible
gem 'rest-client'

# gem 'flex-rails'

# use flex-admin if you need to dump/load/rename/live-reindex
# gem 'flex-admin'

gem 'elasticsearch', git: 'git://github.com/elasticsearch/elasticsearch-ruby.git'
gem 'elasticsearch-model', git: 'git://github.com/elasticsearch/elasticsearch-rails.git'
gem 'elasticsearch-rails', git: 'git://github.com/elasticsearch/elasticsearch-rails.git'
gem 'elasticsearch-extensions', git: 'git://github.com/elasticsearch/elasticsearch-ruby.git'

gem 'tire'

gem 'therubyracer'
gem 'twitter-bootswatch-rails', :github => 'scottvrosenthal/twitter-bootswatch-rails'

# Maps representation documents from and to Ruby objects. Includes JSON, XML and YAML support, plain properties and compositions
gem 'representable'

gem 'hashie'

gem 'whenever'

group :development, :test do
  # Rspec
  gem 'rspec-rails', '~> 2.6'
  gem 'rspec-rails-mocha', '~> 0.3.1', :require => false

  # Spork
  gem 'spork', :github => 'sporkrb/spork'
  gem 'spork-rails', :github => 'sporkrb/spork-rails'

  # Guard
  gem 'growl'
  gem 'rb-fsevent', :require => false if RUBY_PLATFORM =~ /darwin/i
  gem 'guard-bundler'
  gem 'guard-rspec'
  gem 'guard-spork'
end