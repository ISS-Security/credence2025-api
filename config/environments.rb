# frozen_string_literal: true

require 'roda'
require 'figaro'
require 'logger'
require 'sequel'
require './app/lib/secure_db'

module Credence
  # Configuration for the API
  class Api < Roda
    plugin :environments

    # rubocop:disable Lint/ConstantDefinitionInBlock
    configure do
      # load config secrets into local environment variables (ENV)
      Figaro.application = Figaro::Application.new(
        environment: environment,
        path: File.expand_path('config/secrets.yml')
      )
      Figaro.load
      def self.config = Figaro.env

      # Database Setup
      db_url = ENV.delete('DATABASE_URL')
      DB = Sequel.connect("#{db_url}?encoding=utf8")
      def self.DB = DB # rubocop:disable Naming/MethodName

      # Load crypto keys
      SecureDB.setup(ENV.delete('DB_KEY'))

      # Custom events logging
      LOGGER = Logger.new($stderr)
      def self.logger = LOGGER
    end
    # rubocop:enable Lint/ConstantDefinitionInBlock

    # HTTP Request logging
    configure :development, :production do
      plugin :common_logger, $stdout
    end

    configure :development, :test do
      require 'pry'
    end

    configure :test do
      logger.level = Logger::ERROR
    end
  end
end
