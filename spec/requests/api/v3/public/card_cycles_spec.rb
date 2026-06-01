# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Card Cycles' do
  let!(:card_cycle) { CardCycle.find('borealis') }

  describe 'GET /api/v3/public/card_cycles' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/card_cycles', CardCycle.count)
      has_stats_total_count(json, CardCycle.count)
    end
  end

  describe 'GET /api/v3/public/card_cycles/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/card_cycles/#{card_cycle.id}",
        card_cycle.id,
        name: card_cycle.name,
        position: card_cycle.position
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/card_cycles/#{card_cycle.id}",
        card_pools: '/api/v3/public/card_pools',
        card_sets: '/api/v3/public/card_sets',
        cards: '/api/v3/public/cards',
        printings: '/api/v3/public/printings'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/card_cycles/non-existent')
    end
  end
end
