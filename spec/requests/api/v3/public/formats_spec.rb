# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Formats' do
  let!(:format_record) { Format.find('standard') }

  describe 'GET /api/v3/public/formats' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/formats', Format.count)
      has_stats_total_count(json, Format.count)
    end
  end

  describe 'GET /api/v3/public/formats/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/formats/#{format_record.id}",
        format_record.id,
        name: format_record.name
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/formats/#{format_record.id}",
        card_pools: '/api/v3/public/card_pools',
        restrictions: '/api/v3/public/restrictions',
        snapshots: '/api/v3/public/snapshots'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/formats/non-existent')
    end
  end
end
