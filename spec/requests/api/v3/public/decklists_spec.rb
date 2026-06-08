# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Decklists' do
  let!(:decklist) { Decklist.find('11111111-1111-1111-1111-111111111111') }

  describe 'GET /api/v3/public/decklists' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/decklists', Decklist.count)
      has_stats_total_count(json, Decklist.count)
    end
  end

  describe 'GET /api/v3/public/decklists/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/decklists/#{decklist.id}",
        decklist.id,
        name: decklist.name,
        side_id: decklist.side_id
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/decklists/#{decklist.id}",
        cards: '/api/v3/public/cards',
        faction: '/api/v3/public/factions',
        side: '/api/v3/public/sides'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/decklists/00000000-0000-0000-0000-000000000000')
    end
  end
end
