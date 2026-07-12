class UpdateUnifiedCardsToVersion12 < ActiveRecord::Migration[8.1]
  def change
    update_view :unified_cards,
      version: 12,
      revert_to_version: 11,
      materialized: true

    add_index :unified_cards, :id
    add_index :unified_cards, :side_id
    add_index :unified_cards, :faction_id
    add_index :unified_cards, :card_type_id
  end
end
