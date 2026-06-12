# frozen_string_literal: true

class AddMax3PointAgendasToRestrictions < ActiveRecord::Migration[8.1]
  def change
    add_column :restrictions, :max_3_point_agendas, :integer
  end
end
