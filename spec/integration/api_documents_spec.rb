# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Document Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:projects].each do |project_data|
      Credence::Project.create(project_data)
    end
  end

  it 'HAPPY: should be able to get list of all documents' do
    proj = Credence::Project.first
    DATA[:documents].each do |doc|
      proj.add_document(doc)
    end

    get "api/v1/projects/#{proj.id}/documents"
    _(last_response.status).must_equal 200

    result = JSON.parse(last_response.body)['data']
    _(result.count).must_equal 4
    result.each do |doc|
      _(doc['type']).must_equal 'document'
    end
  end

  it 'HAPPY: should be able to get details of a single document' do
    doc_data = DATA[:documents][1]
    proj = Credence::Project.first
    doc = proj.add_document(doc_data)

    get "/api/v1/projects/#{proj.id}/documents/#{doc.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['attributes']['id']).must_equal doc.id
    _(result['attributes']['filename']).must_equal doc_data['filename']
  end

  it 'SAD: should return error if unknown document requested' do
    proj = Credence::Project.first
    get "/api/v1/projects/#{proj.id}/documents/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Documents' do
    before do
      @proj = Credence::Project.first
      @doc_data = DATA[:documents][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new documents' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/projects/#{@proj.id}/documents",
           @doc_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.headers['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      doc = Credence::Document.first

      _(created['id']).must_equal doc.id
      _(created['filename']).must_equal @doc_data['filename']
      _(created['description']).must_equal @doc_data['description']
    end

    it 'SECURITY: should not create documents with mass assignment' do
      bad_data = @doc_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/projects/#{@proj.id}/documents",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.headers['Location']).must_be_nil
    end
  end
end
