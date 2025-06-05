# frozen_string_literal: true

require 'json'

module Credence
  # An authorized account includes auth_token and scope
  class AuthorizedAccount
    attr_reader :account, :scope

    def initialize(account, auth_scope)
      @account = account
      @scope = AuthScope.new(auth_scope)
    end

    def token
      @token ||= AuthToken.create(account, scope)
    end

    def to_h
      {
        type: 'authorized_account',
        attributes: {
          account: account,
          auth_token: token
        }
      }
    end

    def to_json(options = {})
      JSON(to_h, options)
    end
  end
end
