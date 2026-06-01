# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Restrictions' do
  let!(:restriction) { Restriction.find('standard_global_penalty') }

  describe 'GET /api/v3/public/restrictions' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/restrictions', Restriction.count)
      has_stats_total_count(json, Restriction.count)
    end
  end

  describe 'GET /api/v3/public/restrictions/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/restrictions/#{restriction.id}",
        restriction.id,
        name: restriction.name,
        format_id: restriction.format_id
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/restrictions/#{restriction.id}",
        format: '/api/v3/public/formats'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/restrictions/non-existent')
    end
  end
end
