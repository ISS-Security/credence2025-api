# frozen_string_literal: true

module Credence
  # HTTP Request helper methods
  class HttpRequest
    def initialize(roda_routing)
      @routing = roda_routing
    end

    def secure?
      raise 'Secure scheme not configured' unless Api.config.SECURE_SCHEME

      @routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    def authenticated_account
      return nil unless @routing.headers['AUTHORIZATION']

      scheme, auth_token = @routing.headers['AUTHORIZATION'].split
      account_payload = AuthToken.new(auth_token).payload
      scheme.match?(/^Bearer$/i) ? account_payload['attributes'] : nil
    end

    def body_data
      JSON.parse(@routing.body.read, symbolize_names: true)
    end
  end
end
