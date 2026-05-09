# frozen_string_literal: true

# Public resource for the PublishedDatabase object.
class PublishedDatabaseResource < ApplicationResource
  primary_endpoint '/published_databases', [:index]

  attribute :url, :string
  attribute :updated_at, :datetime
  attribute :created_at, :datetime

  def base_scope
    latest_id = PublishedDatabase.order(created_at: :desc).select(:id).limit(1)
    PublishedDatabase.where(id: latest_id)
  end

  # Only return the latest database.
  def default_page_size
    1
  end
end
