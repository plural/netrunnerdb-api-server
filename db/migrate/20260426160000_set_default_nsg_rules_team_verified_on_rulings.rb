# frozen_string_literal: true

class SetDefaultNsgRulesTeamVerifiedOnRulings < ActiveRecord::Migration[7.0]
  def change
    change_column_default :rulings, :nsg_rules_team_verified, from: nil, to: false
  end
end
