# frozen_string_literal: true

require 'roda'
require 'json'

require_relative 'http_request'

module Credence
  # Web controller for Credence API
  class Api < Roda
    plugin :halt
    plugin :multi_route
    plugin :request_headers

    route do |routing|
      response['Content-Type'] = 'application/json'
      request = HttpRequest.new(routing)

      request.secure? ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      begin
        @auth_account = request.authenticated_account
      rescue AuthToken::InvalidTokenError
        routing.halt 403, { message: 'Invalid auth token' }.to_json
      end

      routing.root do
        { message: 'CredenceAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        end
      end
    end
  end
end
