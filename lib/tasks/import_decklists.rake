# frozen_string_literal: true

require 'json'
require 'net/http'
require 'optparse'
require 'uri'

namespace :import_decklists do
  desc 'import card data - json_dir defaults to /netrunner-cards-json/v2/ if not specified.'

  def retrieve_decklists(date)
    url = URI("https://netrunnerdb.com/api/2.0/public/decklists/by_date/#{date}")

    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    request = Net::HTTP::Get.new(url)

    response = http.request(request)

    return JSON.parse(response.body) if response.is_a?(Net::HTTPSuccess)

    raise "Failed to retrieve decklists! Status code: #{response.code}"
  end

  task :import, [:date] => [:environment] do |_t, args|
    args.with_defaults(date: '/netrunner-cards-json/v2/')

    puts "Import decklists for date #{args[:date]}..."

    printings = Printing.all
    printing_to_card = {}
    printings.each do |printing|
      printing_to_card[printing.id] = printing.card_id
    end

    cards = Card.all
    cards_by_id = {}
    cards.each do |card|
      cards_by_id[card.id] = card
    end

    force_import = ENV['FORCE_IMPORT'] == '1'
    puts 'FORCE_IMPORT is set to 1. All decklists will be imported.' if force_import

    decklists = retrieve_decklists(args[:date])['data'] || []
    fetched_count = decklists.size
    puts "Fetched #{fetched_count} decklist(s) from the API."

    uuids = decklists.pluck('uuid').compact
    existing_uuids = Decklist.where(id: uuids).pluck(:id).to_set

    decklists_to_import = if force_import
                            decklists
                          else
                            decklists.reject { |d| existing_uuids.include?(d['uuid']) }
                          end

    written_count = 0
    decklists_to_import.each do |decklist|
      puts format('Importing "%<name>s" by %<username>s (%<uuid>s)',
                  name: decklist['name'],
                  username: decklist['user_name'],
                  uuid: decklist['uuid'])

      ActiveRecord::Base.transaction do
        User.find_or_create_by!(id: decklist['user_name'])

        d = Decklist.find_or_initialize_by(id: decklist['uuid'])
        d.name = decklist['name']
        d.user_id = decklist['user_name']

        d.created_at = DateTime.parse(decklist['date_creation'])
        d.updated_at = DateTime.parse(decklist['date_update'])
        d.notes = decklist['description']

        decklist['cards'].each_key do |printing_id|
          card = cards_by_id[printing_to_card[printing_id]]
          if %w[corp_identity runner_identity].include?(card.card_type_id)
            d.identity_card_id = card.id
            d.side_id = card.side_id
          end
        end

        d.save!

        # To allow overwriting, clear out the existing cards.
        d.decklist_cards.delete_all
        d.decklist_cards << d.decklist_cards.build(card_id: d.identity_card_id, quantity: 1)
        decklist['cards'].each do |printing_id, quantity|
          card = cards_by_id[printing_to_card[printing_id]]
          # Do not write identity cards to the decklist_cards table.
          unless %w[corp_identity runner_identity].include?(card.card_type_id)
            d.decklist_cards << d.decklist_cards.build(card_id: printing_to_card[printing_id], quantity:)
          end
        end
      end
      written_count += 1
    end

    if force_import
      puts "Imported/updated #{written_count} decklist(s) out of #{fetched_count} fetched."
    else
      puts "Imported #{written_count} new decklist(s) out of #{fetched_count} fetched."
    end
  end
end
