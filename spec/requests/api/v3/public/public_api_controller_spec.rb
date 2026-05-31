# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Exception Handling' do
  describe 'GET /api/v3/public/card_cycles/:id' do
    context 'when the record does not exist' do
      it 'returns a valid JSON API error response' do
        get '/api/v3/public/card_cycles/non-existent'

        expect(response).to have_http_status(:not_found)
        expect(response.content_type).to match(%r{application/(json|vnd\.api\+json)})

        json = JSON.parse(response.body) # rubocop:disable Rails/ResponseParsedBody
        expect(json).to have_key('errors')
        expect(json['errors']).to be_an(Array)
        expect(json['errors'].first['status']).to eq('404')
        expect(json['errors'].first['title']).to eq('Not Found')
      end
    end
  end

  describe 'GET /api/v3/public/card_cycles' do
    context 'when a standard error occurs' do
      before do
        allow(CardCycleResource).to receive(:all).and_raise(StandardError.new('Something went wrong'))
      end

      it 'returns a 500 JSON API error response' do
        get '/api/v3/public/card_cycles'

        expect(response).to have_http_status(:internal_server_error)
        expect(response.content_type).to match(%r{application/(json|vnd\.api\+json)})

        json = JSON.parse(response.body) # rubocop:disable Rails/ResponseParsedBody
        expect(json).to have_key('errors')
        expect(json['errors']).to be_an(Array)
        expect(json['errors'].first['status']).to eq('500')
        expect(json['errors'].first['title']).to eq('Internal Server Error')
        expect(json['errors'].first['detail']).to eq(
          "We've notified our engineers and hope to address this issue shortly."
        )
      end
    end
  end
end
