# frozen_string_literal: true

class AddCardIdDecklistIdIndexToDecklistsCards < ActiveRecord::Migration[8.1]
  def change
    add_index :decklists_cards, %i[card_id decklist_id]
  end
end
