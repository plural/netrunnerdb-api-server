# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Card Types' do
  let!(:card_type) { CardType.find('agenda') }

  describe 'GET /api/v3/public/card_types' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/card_types', CardType.count)
      has_stats_total_count(json, CardType.count)
    end
  end

  describe 'GET /api/v3/public/card_types/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/card_types/#{card_type.id}",
        card_type.id,
        name: card_type.name
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/card_types/#{card_type.id}",
        cards: '/api/v3/public/cards',
        printings: '/api/v3/public/printings',
        side: '/api/v3/public/sides'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/card_types/non-existent')
    end
  end
end
