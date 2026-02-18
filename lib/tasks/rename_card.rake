# frozen_string_literal: true

require 'optparse'

# Example usage:
#   Dry run:     bundle exec rake card:rename[card_id,new_id]
#   Actual run:  bundle exec rake card:rename[card_id,new_id,false]
namespace :card do
  desc 'import card data - json_dir defaults to /netrunner-cards-json/v2/ if not specified.'

  def sanitize_sql(table_name, old_id, new_id)
    ActiveRecord::Base.sanitize_sql_array(
      [
        "UPDATE #{table_name} SET card_id = :new_card_id WHERE card_id = :old_card_id",
        { new_card_id: new_id, old_card_id: old_id }
      ]
    )
  end

  def sanitize_identity_card_id_sql(table_name, old_id, new_id)
    ActiveRecord::Base.sanitize_sql_array(
      [
        "UPDATE #{table_name} SET identity_card_id = :new_card_id WHERE identity_card_id = :old_card_id",
        { new_card_id: new_id, old_card_id: old_id }
      ]
    )
  end

  task :rename, %i[card_id new_id dry_run] => [:environment] do |_t, args|
    dry_run = true
    dry_run = false if args[:dry_run].present? && args[:dry_run].to_s.downcase == 'false'

    puts "Renaming card #{args[:card_id]} to #{args[:new_id]}"

    old_card = RawCard.find_by(id: args[:card_id])
    if old_card.nil?
      puts "Card with id #{args[:card_id]} not found. Exiting."
      exit(1)
    end

    new_card = RawCard.find_by(id: args[:new_id])
    unless new_card.nil?
      puts "Card with new id #{args[:new_id]} already exists. Exiting."
      exit(1)
    end

    ActiveRecord::Base.transaction do
      new_card = old_card.dup
      new_card.id = args[:new_id]
      new_card.title = "#{new_card.title} (Renamed)"
      new_card.save!

      # Manually update tables that reference the old card_id.
      puts "Updating references from card_id #{old_card.id} to #{new_card.id} in related tables..."

      %w[
        card_faces
        card_faces_card_subtypes
        card_pools_cards
        cards_card_subtypes
        decklists_cards
        decks_cards
        printings
        restrictions_cards_banned
        restrictions_cards_global_penalty
        restrictions_cards_points
        restrictions_cards_restricted
        restrictions_cards_universal_faction_cost
        reviews
        rulings
      ].each do |table_name|
        puts "    Updating #{table_name}..."
        ActiveRecord::Base.connection.execute(
          sanitize_sql(table_name, old_card.id, new_card.id)
        )
      rescue StandardError => e
        puts "Error updating #{table_name}: #{e.message}"
        raise ActiveRecord::Rollback
      end

      %w[decklists decks].each do |table_name|
        puts "    Updating #{table_name}..."
        ActiveRecord::Base.connection.execute(
          sanitize_identity_card_id_sql(table_name, old_card.id, new_card.id)
        )
      rescue StandardError => e
        puts "Error updating #{table_name}: #{e.message}"
        raise ActiveRecord::Rollback
      end

      puts "Updates done.  Deleting old card #{old_card.id} and fixing title..."
      new_card.title = old_card.title
      old_card.delete
      new_card.save

      if dry_run
        puts 'Rolling back due to dry run...'
        raise ActiveRecord::Rollback
      else
        puts 'Refreshing materialized view for restrictions...'
        Scenic.database.refresh_materialized_view(:unified_restrictions, concurrently: false, cascade: false)

        puts 'Refreshing materialized view for cards...'
        Scenic.database.refresh_materialized_view(:unified_cards, concurrently: false, cascade: false)

        puts 'Refreshing materialized view for printings...'
        Scenic.database.refresh_materialized_view(:unified_printings, concurrently: false, cascade: false)
      end
    end
  end
end
