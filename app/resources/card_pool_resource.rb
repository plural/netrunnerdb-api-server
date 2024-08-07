# frozen_string_literal: true

# Public Resource for CardPool objects.
class CardPoolResource < ApplicationResource
  primary_endpoint '/card_pools', %i[index show]

  attribute :id, :string
  attribute :name, :string
  attribute :format_id, :string
  attribute :card_cycle_ids, :array_of_strings
  attribute :updated_at, :datetime
  attribute :num_cards, :integer

  belongs_to :format
  many_to_many :card_cycles
  many_to_many :card_sets
  has_many :snapshots

  # TODO(plural): Add working relationships for cards and printings.
  many_to_many :cards
  many_to_many :printings

  filter :printing_id, :string do
    eq do |scope, value|
      scope.by_printing_ids(value)
    end
  end
end
