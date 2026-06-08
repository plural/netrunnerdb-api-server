# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Card Set Types' do
  let!(:card_set_type) { CardSetType.find('booster_pack') }

  describe 'GET /api/v3/public/card_set_types' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/card_set_types', CardSetType.count)
      has_stats_total_count(json, CardSetType.count)
    end
  end

  describe 'GET /api/v3/public/card_set_types/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/card_set_types/#{card_set_type.id}",
        card_set_type.id,
        name: card_set_type.name,
        description: card_set_type.description
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/card_set_types/#{card_set_type.id}",
        card_sets: '/api/v3/public/card_sets'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/card_set_types/non-existent')
    end
  end
end
