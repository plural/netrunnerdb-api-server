# frozen_string_literal: true

# Model for comments on reviews.
class ReviewComment < ApplicationRecord
  belongs_to :review
  belongs_to :user, optional: true
end
