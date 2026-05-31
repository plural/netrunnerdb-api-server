# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Sides' do
  let!(:side) { Side.find('corp') }

  describe 'GET /api/v3/public/sides' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/sides', Side.count)
      has_stats_total_count(json, Side.count)
    end
  end

  describe 'GET /api/v3/public/sides/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/sides/#{side.id}",
        side.id,
        name: side.name
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/sides/#{side.id}",
        card_types: '/api/v3/public/card_types',
        cards: '/api/v3/public/cards',
        decklists: '/api/v3/public/decklists',
        factions: '/api/v3/public/factions',
        printings: '/api/v3/public/printings'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/sides/non-existent')
    end
  end
end
