# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Rulings' do
  let!(:ruling) { Ruling.find(1) }

  describe 'GET /api/v3/public/rulings' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/rulings', Ruling.count)
      has_stats_total_count(json, Ruling.count)
    end
  end

  describe 'GET /api/v3/public/rulings/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/rulings/#{ruling.id}",
        ruling.id,
        card_id: ruling.card_id
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/rulings/#{ruling.id}",
        card: '/api/v3/public/cards'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/rulings/999999')
    end
  end
end
