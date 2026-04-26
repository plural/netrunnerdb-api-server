# frozen_string_literal: true

# Join model connecting CardFace objects to CardSubtype objects.
class CardFaceCardSubtype < ApplicationRecord
  self.table_name = 'card_faces_card_subtypes'

  belongs_to :card_face, # rubocop:disable Rails/InverseOf
             primary_key: %i[card_id face_index],
             foreign_key: %i[card_id face_index]
  belongs_to :card_subtype,
             primary_key: :id
end
