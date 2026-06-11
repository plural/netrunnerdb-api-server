# frozen_string_literal: true

class AddDeckbuildingRestrictionsToRestrictions < ActiveRecord::Migration[8.1]
  def change
    add_column :restrictions, :deckbuilding_restrictions, :jsonb, default: {}, null: false
  end
end
