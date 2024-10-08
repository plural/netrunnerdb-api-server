# frozen_string_literal: true

class AddSideIdToCardTypes < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :card_types, :side_id, :string
    add_foreign_key :card_types, :sides
  end
end
