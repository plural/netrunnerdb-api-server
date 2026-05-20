# frozen_string_literal: true

# Model for User objects.
#
# This object will remain fairly lean since user management will not be handled in the application itself.
class User < ApplicationRecord
  has_many :decks
  has_many :decklists
  has_many :reviews
  has_many :review_comments
  has_many :review_votes
end
