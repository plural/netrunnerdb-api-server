# frozen_string_literal: true

# Model for votes on reviews.
class ReviewVote < ApplicationRecord
  belongs_to :review
  belongs_to :user, optional: true
end
