class UpdateUnifiedPrintingsToVersion14 < ActiveRecord::Migration[8.1]
  def change
    update_view :unified_printings,
      version: 14,
      revert_to_version: 13,
      materialized: true

    add_index :unified_printings, :id
    add_index :unified_printings, :side_id
    add_index :unified_printings, :faction_id
    add_index :unified_printings, :card_type_id
    add_index :unified_printings, :card_cycle_id
    add_index :unified_printings, :card_set_id
  end
end
