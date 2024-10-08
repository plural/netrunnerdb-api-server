# frozen_string_literal: true

class RenameReviewUsernameToUserId < ActiveRecord::Migration[7.1] # rubocop:disable Style/Documentation
  def change
    change_table :reviews do |t|
      t.remove :username # rubocop:disable Rails/ReversibleMigration
    end
    add_reference :reviews, :user, type: :string

    change_table :review_comments do |t|
      t.remove :username # rubocop:disable Rails/ReversibleMigration
    end
    add_reference :review_comments, :user, type: :string

    change_table :review_votes do |t|
      # temporary, actual usernames not available yet, using placeholder values instead
      t.rename :username, :user_id
    end
  end
end
