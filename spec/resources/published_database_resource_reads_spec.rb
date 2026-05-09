# frozen_string_literal: true

require 'rails_helper'

RSpec.describe PublishedDatabaseResource, type: :resource do
  describe 'serialization' do
    fixtures :published_databases

    let(:new_db) { published_databases(:latest_db) }

    it 'works and only returns the latest database' do
      render
      data = jsonapi_data

      expect(data.length).to eq(1)

      record = data[0]
      expect(record.url).to eq(new_db.url)
      expect(Time.parse(record.created_at).to_i).to eq(new_db.created_at.to_i)
      expect(record.jsonapi_type).to eq('published_databases')
    end
  end
end
