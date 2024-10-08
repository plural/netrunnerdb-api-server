# frozen_string_literal: true

# Model for Restriction objects.
class Restriction < ApplicationRecord
  has_many :snapshots

  belongs_to :format

  has_one :restriction_card_banned
  has_many :banned_cards, through: :restriction_card_banned, source: :card

  has_one :restriction_card_restricted
  has_many :restricted_cards, through: :restriction_card_restricted, source: :card

  has_one :restriction_card_universal_faction_cost
  has_many :universal_faction_cost_cards, through: :restriction_card_universal_faction_cost, source: :card

  has_one :restriction_card_global_penalty
  has_many :global_penalty_cards, through: :restriction_card_global_penalty, source: :card

  has_one :restriction_card_points
  has_many :points_cards, through: :restriction_card_points, source: :card

  has_one :restriction_card_subtype_banned
  has_many :banned_subtypes, through: :restriction_card_subtype_banned, source: :card_subtype

  # TODO(plural): Add an index for this uniqueness constraint.
  validates :name, uniqueness: true # rubocop:disable Rails/UniqueValidationWithoutIndex

  # TODO(plural): Make date_start a proper date type.

  def verdicts
    # TODO(plural): Memoize this function.
    {
      banned: banned_cards.pluck(:card_id),
      restricted: restricted_cards.pluck(:card_id),
      universal_faction_cost: universal_faction_cost_cards.pluck(:card_id, :value).to_h,
      global_penalty: global_penalty_cards.pluck(:card_id),
      points: points_cards.pluck(:card_id, :value).to_h
    }
  end

  def size
    verdicts.map { |(_, v)| v.length }.sum
  end
end
