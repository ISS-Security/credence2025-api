# frozen_string_literal: true

require 'http'

module Credence
  # Authenticate an SSO acocunt by finding or creating one based on Github data
  class AuthenticateSso
    def call(access_token)
      github_account = get_github_account(access_token)
      sso_account = find_or_create_sso_account(github_account)

      AuthorizedAccount.new(sso_account, AuthScope::FULL).to_h
    end

    def get_github_account(access_token)
      gh_response = HTTP.headers(
        user_agent: 'Credence',
        authorization: "token #{access_token}",
        accept: 'application/json'
      ).get(ENV.fetch('GITHUB_ACCOUNT_URL'))

      raise unless gh_response.status == 200

      account = GithubAccount.new(JSON.parse(gh_response))
      { username: account.username, email: account.email }
    end

    def find_or_create_sso_account(account_data)
      Account.first(email: account_data[:email]) ||
        Account.create_github_account(account_data)
    end
  end
end
