# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  Credence::Document.map(&:destroy)
  Credence::Project.map(&:destroy)
  Credence::Account.map(&:destroy)
end

DATA = {
  accounts: YAML.load_file('db/seeds/accounts_seed.yml'),
  documents: YAML.load_file('db/seeds/documents_seed.yml'),
  projects: YAML.load_file('db/seeds/projects_seed.yml')
}.freeze
