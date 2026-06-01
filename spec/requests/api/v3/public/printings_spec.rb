# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Printings' do
  let!(:printing) { Printing.find('21166') }

  describe 'GET /api/v3/public/printings' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/printings', Printing.count)
      has_stats_total_count(json, Printing.count)
    end
  end

  describe 'GET /api/v3/public/printings/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/printings/#{printing.id}",
        printing.id,
        title: printing.title,
        card_id: printing.card_id,
        card_cycle_id: printing.card_cycle_id,
        card_set_id: printing.card_set_id
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/printings/#{printing.id}",
        card: '/api/v3/public/cards',
        card_cycle: '/api/v3/public/card_cycles',
        card_pools: '/api/v3/public/card_pools',
        card_set: '/api/v3/public/card_sets',
        card_subtypes: '/api/v3/public/card_subtypes',
        card_type: '/api/v3/public/card_types',
        faction: '/api/v3/public/factions',
        illustrators: '/api/v3/public/illustrators',
        side: '/api/v3/public/sides'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/printings/non-existent')
    end
  end
end
