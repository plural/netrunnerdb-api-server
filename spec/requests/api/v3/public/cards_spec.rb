# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Cards' do
  let!(:card) { Card.find('legwork') }

  describe 'GET /api/v3/public/cards' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/cards', Card.count)
      has_stats_total_count(json, Card.count)
    end
  end

  describe 'GET /api/v3/public/cards/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/cards/#{card.id}",
        card.id,
        title: card.title,
        side_id: card.side_id,
        faction_id: card.faction_id
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/cards/#{card.id}",
        card_cycles: '/api/v3/public/card_cycles',
        card_pools: '/api/v3/public/card_pools',
        card_sets: '/api/v3/public/card_sets',
        card_subtypes: '/api/v3/public/card_subtypes',
        card_type: '/api/v3/public/card_types',
        decklists: '/api/v3/public/decklists',
        faction: '/api/v3/public/factions',
        printings: '/api/v3/public/printings',
        reviews: '/api/v3/public/reviews',
        rulings: '/api/v3/public/rulings',
        side: '/api/v3/public/sides'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/cards/non-existent')
    end
  end
end
