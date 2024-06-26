# frozen_string_literal: true

# Public resource for Decklist objects.
class DecklistResource < ApplicationResource
  primary_endpoint '/decklists', %i[index show]

  attribute :id, :uuid
  attribute :user_id, :string
  attribute :follows_basic_deckbuilding_rules, :boolean
  attribute :identity_card_id, :string
  attribute :name, :string
  attribute :notes, :string
  attribute :tags, :array_of_strings
  attribute :side_id, :string
  attribute :created_at, :datetime
  attribute :updated_at, :datetime

  attribute :faction_id, :string, filterable: true do
    id = Card.find(@object.identity_card_id)
    id&.faction_id
  end

  filter :faction_id, :string do
    eq do |scope, value|
      scope.by_faction(value)
    end
  end

  attribute :card_slots, :hash do
    cards = {}
    @object.decklist_cards.order(:card_id).each do |c|
      cards[c.card_id] = c.quantity
    end
    cards
  end

  attribute :num_cards, :integer do
    @object.decklist_cards.map(&:quantity).sum
  end

  # This is the basic definition, but does not take restriction modifications
  # into account. Leaving this here as an example for now, but it will need to
  # be removed in favor of snapshot-specific calculations.
  attribute :influence_spent, :integer do
    qty = {}
    @object.decklist_cards.each do |c|
      qty[c.card_id] = c.quantity
    end
    id = Card.find(@object.identity_card_id)
    @object.cards
           .filter { |c| c.faction_id != id.faction_id }
           .map { |c| c.influence_cost.nil? ? 0 : (c.influence_cost * qty[c.id]) }
           .sum
  end

  belongs_to :side
  # TODO(plural): Fix the faction relationship so includes work for it.
  belongs_to :faction do
    link do |decklist|
      '%s/%s' % [ Rails.application.routes.url_helpers.factions_url, decklist.faction_id ]
    end
  end

  belongs_to :identity_card, resource: CardResource do #, foreign_key: :identity_card_id do
    link do |decklist|
      '%s/%s' % [ Rails.application.routes.url_helpers.cards_url, decklist.identity_card_id ]
    end
  end

  many_to_many :cards
end
