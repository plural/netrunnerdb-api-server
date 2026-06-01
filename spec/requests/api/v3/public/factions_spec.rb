# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Factions' do
  let!(:faction) { Faction.find('haas_bioroid') }

  describe 'GET /api/v3/public/factions' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/factions', Faction.count)
      has_stats_total_count(json, Faction.count)
    end
  end

  describe 'GET /api/v3/public/factions/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/factions/#{faction.id}",
        faction.id,
        name: faction.name,
        side_id: faction.side_id
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/factions/#{faction.id}",
        cards: '/api/v3/public/cards',
        decklists: '/api/v3/public/decklists',
        printings: '/api/v3/public/printings',
        side: '/api/v3/public/sides'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/factions/non-existent')
    end
  end
end
