class CreatePublishedDatabases < ActiveRecord::Migration[8.1]
  def change
    create_table :published_databases do |t|
      t.string :url, null: false
      t.timestamps
    end
  end
end
