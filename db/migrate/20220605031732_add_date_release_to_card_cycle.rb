# frozen_string_literal: true

class AddDateReleaseToCardCycle < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    add_column :card_cycles, :date_release, :date
  end
end
