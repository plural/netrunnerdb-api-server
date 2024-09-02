class AddIndexesToUnifiedViews < ActiveRecord::Migration[7.1]
  def change
    add_index :unified_cards, :id
    add_index :unified_cards, :card_type_id
    add_index :unified_cards, :side_id
    add_index :unified_cards, :faction_id
    add_index :unified_printings, :card_id
    add_index :unified_printings, :id
    add_index :unified_printings, :card_type_id
    add_index :unified_printings, :side_id
    add_index :unified_printings, :faction_id
    add_index :unified_printings, :card_cycle_id
    add_index :unified_printings, :card_set_id
  end
end
