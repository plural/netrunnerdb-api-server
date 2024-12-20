# frozen_string_literal: true

# Public resource for Snapshot objects.
class SnapshotResource < ApplicationResource
  primary_endpoint '/snapshots', %i[index show]

  self.default_page_size = 1000

  attribute :id, :string
  attribute :format_id, :string
  attribute :active, :boolean
  attribute :card_cycle_ids, :array_of_strings do
    @object.card_cycle_ids
  end
  attribute :card_set_ids, :array_of_strings do
    @object.card_set_ids
  end
  attribute :card_pool_id, :string
  attribute :restriction_id, :string
  attribute :num_cards, :integer do
    @object.card_pool.cards.count
  end
  attribute :date_start, :date
  attribute :updated_at, :datetime

  belongs_to :format

  belongs_to :card_pool
  belongs_to :restriction
end
