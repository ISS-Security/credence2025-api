# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Project Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting projects' do
    describe 'Getting list of projects' do
      before do
        @account_data = DATA[:accounts][0]
        account = Credence::Account.create(@account_data)
        account.add_owned_project(DATA[:projects][0])
        account.add_owned_project(DATA[:projects][1])
      end

      it 'HAPPY: should get list for authorized account' do
        auth = Credence::AuthenticateAccount.call(
          username: @account_data['username'],
          password: @account_data['password']
        )

        header 'AUTHORIZATION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/projects'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'BAD: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/projects'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single project' do
      existing_proj = DATA[:projects][1]
      Credence::Project.create(existing_proj)
      id = Credence::Project.first.id

      get "/api/v1/projects/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['id']).must_equal id
      _(result['attributes']['name']).must_equal existing_proj['name']
    end

    it 'SAD: should return error if unknown project requested' do
      get '/api/v1/projects/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      Credence::Project.create(name: 'New Project')
      Credence::Project.create(name: 'Newer Project')
      get 'api/v1/projects/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Projects' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @proj_data = DATA[:projects][1]
    end

    it 'HAPPY: should be able to create new projects' do
      post 'api/v1/projects', @proj_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      proj = Credence::Project.first

      _(created['id']).must_equal proj.id
      _(created['name']).must_equal @proj_data['name']
      _(created['repo_url']).must_equal @proj_data['repo_url']
    end

    it 'SECURITY: should not create project with mass assignment' do
      bad_data = @proj_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/projects', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
