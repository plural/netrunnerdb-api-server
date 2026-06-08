# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Card Pools' do
  let!(:card_pool) { CardPool.find('standard_02') }

  describe 'GET /api/v3/public/card_pools' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/card_pools', CardPool.count)
      has_stats_total_count(json, CardPool.count)
    end
  end

  describe 'GET /api/v3/public/card_pools/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/card_pools/#{card_pool.id}",
        card_pool.id,
        name: card_pool.name,
        format_id: card_pool.format_id
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/card_pools/#{card_pool.id}",
        card_cycles: '/api/v3/public/card_cycles',
        card_sets: '/api/v3/public/card_sets',
        cards: '/api/v3/public/cards',
        format: '/api/v3/public/formats',
        printings: '/api/v3/public/printings',
        snapshots: '/api/v3/public/snapshots'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/card_pools/non-existent')
    end
  end
end
