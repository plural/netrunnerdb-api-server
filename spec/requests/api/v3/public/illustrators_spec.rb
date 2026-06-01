# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Public API Illustrators' do
  let!(:illustrator) { Illustrator.find('tom_of_netrunner') }

  describe 'GET /api/v3/public/illustrators' do
    it 'returns a successful 200 response with correct count' do
      json = api_num_results('/api/v3/public/illustrators', Illustrator.count)
      has_stats_total_count(json, Illustrator.count)
    end
  end

  describe 'GET /api/v3/public/illustrators/:id' do
    it 'matches existing record' do
      matches_record(
        "/api/v3/public/illustrators/#{illustrator.id}",
        illustrator.id,
        name: illustrator.name
      )
    end

    it 'has expected relationships' do
      has_relationships(
        "/api/v3/public/illustrators/#{illustrator.id}",
        printings: '/api/v3/public/printings'
      )
    end

    it 'does not match missing record' do
      missing_record('/api/v3/public/illustrators/non-existent')
    end
  end
end
