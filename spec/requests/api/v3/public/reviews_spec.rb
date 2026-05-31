# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Reviews' do
  let!(:review) { Review.find(1) }

  describe 'GET /api/v3/public/reviews' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/reviews', Review.count)
      has_stats_total_count(json, Review.count)
    end
  end

  describe 'GET /api/v3/public/reviews/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/reviews/#{review.id}",
        review.id,
        card_id: review.card_id
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/reviews/#{review.id}",
        card: '/api/v3/public/cards'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/reviews/999999')
    end
  end
end
