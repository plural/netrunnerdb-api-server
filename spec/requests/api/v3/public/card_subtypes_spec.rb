# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Card Subtypes' do
  let!(:card_subtype) { CardSubtype.find('advertisement') }

  describe 'GET /api/v3/public/card_subtypes' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/card_subtypes', CardSubtype.count)
      has_stats_total_count(json, CardSubtype.count)
    end
  end

  describe 'GET /api/v3/public/card_subtypes/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/card_subtypes/#{card_subtype.id}",
        card_subtype.id,
        name: card_subtype.name
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/card_subtypes/#{card_subtype.id}",
        cards: '/api/v3/public/cards',
        printings: '/api/v3/public/printings'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/card_subtypes/non-existent')
    end
  end
end
