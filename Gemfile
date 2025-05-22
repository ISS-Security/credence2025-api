# frozen_string_literal: true

source 'https://rubygems.org'
ruby File.read('.ruby-version').strip

# Web API
gem 'logger', '~> 1.0'
gem 'puma', '~>6.0'
gem 'roda', '~>3.0'

# Configuration
gem 'figaro', '~>1.2'
gem 'rake', '~>13.0'

# Security
gem 'rbnacl', '~>7.1'

# Database
gem 'hirb', '~>0.7'
gem 'sequel', '~>5.67'
group :production do
  gem 'pg'
end

# Data Encoding and Formatting
gem 'base64'
gem 'json'

# External Services
gem 'http'

# Debugging
gem 'pry' # necessary for rake console
gem 'rack-test'

# Development
group :development do
  # Debugging
  gem 'rerun'

  # Quality
  gem 'rubocop'
  gem 'rubocop-minitest'
  gem 'rubocop-performance'
  gem 'rubocop-rake'
  gem 'rubocop-sequel'

  # Audit
  gem 'bundler-audit'
end

# Dev/test Database
group :development, :test do
  gem 'sequel-seed'
  gem 'sqlite3', '~>1.6'
end

# Testing
group :test do
  gem 'minitest'
  gem 'minitest-rg'
end
