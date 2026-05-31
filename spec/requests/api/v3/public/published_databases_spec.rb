# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Published Databases' do
  fixtures :published_databases

  describe 'GET /api/v3/public/published_databases' do
    it 'returns a successful 200 response with correct count' do
      api_num_results('/api/v3/public/published_databases', 1)
    end
  end
end
