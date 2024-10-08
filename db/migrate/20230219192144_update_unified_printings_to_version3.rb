# frozen_string_literal: true

class UpdateUnifiedPrintingsToVersion3 < ActiveRecord::Migration[7.0] # rubocop:disable Style/Documentation
  def change
    update_view :unified_printings, materialized: true, version: 3, revert_to_version: 2
  end
end
