# frozen_string_literal: true

class CardSet < ApplicationRecord
  belongs_to :card_cycle
  belongs_to :card_set_type

  def first_printing_id
    first_printing = Printing.find_by(card_set_id: id, position_in_set: 1)
    first_printing&.id
  end

  has_many :raw_printings
  has_many :printings
  has_many :raw_cards, through: :raw_printings, source: :raw_card
  has_many :cards, through: :printings
end
