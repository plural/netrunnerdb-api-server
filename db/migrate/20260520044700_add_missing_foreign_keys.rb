# frozen_string_literal: true

class AddMissingForeignKeys < ActiveRecord::Migration[8.1]
  def change
    # User constraints
    add_foreign_key :decklists, :users
    add_foreign_key :reviews, :users
    add_foreign_key :review_comments, :users
    add_foreign_key :review_votes, :users

    # card_faces constraints
    add_foreign_key :card_faces, :cards

    # card_faces_card_subtypes constraints
    add_foreign_key :card_faces_card_subtypes, :card_subtypes

    # Composite foreign key for card_faces_card_subtypes -> card_faces
    reversible do |dir|
      dir.up do
        execute <<~SQL
          ALTER TABLE card_faces_card_subtypes
          ADD CONSTRAINT fk_card_faces_card_subtypes_card_faces
          FOREIGN KEY (card_id, face_index)
          REFERENCES card_faces (card_id, face_index);
        SQL
      end
      dir.down do
        execute <<~SQL
          ALTER TABLE card_faces_card_subtypes
          DROP CONSTRAINT fk_card_faces_card_subtypes_card_faces;
        SQL
      end
    end

    # illustrators_printings constraints
    add_foreign_key :illustrators_printings, :illustrators
    add_foreign_key :illustrators_printings, :printings

    # printing_faces constraints
    add_foreign_key :printing_faces, :printings

    # printings_card_subtypes constraints
    add_foreign_key :printings_card_subtypes, :printings
    add_foreign_key :printings_card_subtypes, :card_subtypes
  end
end
