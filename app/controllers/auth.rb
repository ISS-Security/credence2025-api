# frozen_string_literal: true

require 'roda'
require_relative './app'

module Credence
  # Web controller for Credence API
  class Api < Roda
    route('auth') do |routing| # rubocop:disable Metrics/BlockLength
      routing.on 'register' do
        # POST api/v1/auth/register
        routing.post do
          reg_data = JSON.parse(request.body.read, symbolize_names: true)
          VerifyRegistration.new(reg_data).call

          response.status = 202
          { message: 'Verification email sent' }.to_json
        rescue VerifyRegistration::InvalidRegistration => e
          routing.halt 400, { message: e.message }.to_json
        rescue VerifyRegistration::EmailProviderError => e
          Api.logger.error "Could not send registration email: #{e.inspect}"
          routing.halt 500, { message: 'Error sending email' }.to_json
        rescue StandardError => e
          Api.logger.error "Could not verify registration: #{e.inspect}"
          routing.halt 500
        end
      end

      routing.is 'authenticate' do
        # POST /api/v1/auth/authenticate
        routing.post do
          credentials = HttpRequest.new(routing).body_data
          auth_account = AuthenticateAccount.call(credentials)
          { data: auth_account }.to_json
        rescue AuthenticateAccount::UnauthorizedError
          routing.halt '401', { message: 'Invalid credentials' }.to_json
        end
      end

      # POST /api/v1/auth/authenticate/sso
      routing.post 'sso' do
        auth_request = HttpRequest.new(routing).body_data

        auth_account = AuthenticateSso.new.call(auth_request[:access_token])
        { data: auth_account }.to_json
      rescue StandardError => e
        Api.logger.warn "FAILED to validate Github account: #{e.inspect}" \
                        "\n#{e.backtrace}"

        routing.halt 400
      end
    end
  end
end
