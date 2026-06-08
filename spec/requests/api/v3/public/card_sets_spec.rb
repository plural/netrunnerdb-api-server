# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Card Sets' do
  let!(:card_set) { CardSet.find('midnight_sun') }

  describe 'GET /api/v3/public/card_sets' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/card_sets', CardSet.count)
      has_stats_total_count(json, CardSet.count)
    end
  end

  describe 'GET /api/v3/public/card_sets/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/card_sets/#{card_set.id}",
        card_set.id,
        name: card_set.name,
        card_cycle_id: card_set.card_cycle_id,
        card_set_type_id: card_set.card_set_type_id
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/card_sets/#{card_set.id}",
        card_cycle: '/api/v3/public/card_cycles',
        card_pools: '/api/v3/public/card_pools',
        card_set_type: '/api/v3/public/card_set_types',
        cards: '/api/v3/public/cards',
        printings: '/api/v3/public/printings'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/card_sets/non-existent')
    end
  end
end
