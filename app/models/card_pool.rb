# frozen_string_literal: true

# Model for Card Pool objects.
class CardPool < ApplicationRecord
  has_many :card_pool_card_cycles
  has_many :card_cycles, through: :card_pool_card_cycles
  has_many :card_pool_card_sets
  has_many :card_sets, through: :card_pool_card_sets
  has_many :card_pool_cards
  has_many :raw_cards, through: :card_pool_cards
  has_many :cards, through: :card_pool_cards, primary_key: :card_id, foreign_key: :id
  has_many :printings, through: :card_pool_cards, primary_key: :card_id, foreign_key: :card_id
  has_many :snapshots

  belongs_to :format

  def num_cards
    cards.size
  end

  # TODO(plural): Add an index for this uniqueness constraint.
  validates :name, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex

  scope :by_printing_ids, lambda { |printing_ids|
    joins(:card_pool_cards).joins(:printings).where(unified_printings: { id: printing_ids }).distinct
  }
end
