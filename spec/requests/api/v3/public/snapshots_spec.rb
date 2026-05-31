# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Snapshots' do
  let!(:snapshot) { Snapshot.find('standard_05') }

  describe 'GET /api/v3/public/snapshots' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/snapshots', Snapshot.count)
      has_stats_total_count(json, Snapshot.count)
    end
  end

  describe 'GET /api/v3/public/snapshots/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/snapshots/#{snapshot.id}",
        snapshot.id,
        format_id: snapshot.format_id,
        active: snapshot.active
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/snapshots/#{snapshot.id}",
        card_pool: '/api/v3/public/card_pools',
        format: '/api/v3/public/formats',
        restriction: '/api/v3/public/restrictions'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/snapshots/non-existent')
    end
  end
end
