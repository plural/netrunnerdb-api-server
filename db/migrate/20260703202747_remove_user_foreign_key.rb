class RemoveUserForeignKey < ActiveRecord::Migration[8.1]
  def change
    remove_foreign_key :decklists, :users, column: :user_id, if_exists: true
    remove_foreign_key :review_comments, :users, column: :user_id, if_exists: true
    remove_foreign_key :review_votes, :users, column: :user_id, if_exists: true
    remove_foreign_key :reviews, :users, column: :user_id, if_exists: true
  end
end
