namespace :sqlite do
  desc 'Create a sqlite3 database for the specified tables'
  task create: :environment do
    require 'sqlite3'

    db_file = Rails.root.join('db', 'netrunnerdb.sqlite3')
    File.delete(db_file) if File.exist?(db_file)

    # Establish connection to the new SQLite database
    sqlite_db = SQLite3::Database.new(db_file.to_s)

    puts "Creating tables in #{db_file}..."

    # sides
    sqlite_db.execute <<-SQL
      CREATE TABLE sides (
        id text PRIMARY KEY,
        name text NOT NULL,
        created_at datetime NOT NULL,
        updated_at datetime NOT NULL
      );
    SQL

    # factions
    sqlite_db.execute <<-SQL
      CREATE TABLE factions (
        id text PRIMARY KEY,
        is_mini boolean NOT NULL,
        name text NOT NULL,
        side_id text NOT NULL,
        created_at datetime NOT NULL,
        updated_at datetime NOT NULL,
        description varchar
      );
    SQL

    # card_cycles
    sqlite_db.execute <<-SQL
      CREATE TABLE card_cycles (
        id text PRIMARY KEY,
        name text NOT NULL,
        description text,
        created_at datetime NOT NULL,
        updated_at datetime NOT NULL,
        date_release date,
        legacy_code varchar,
        released_by varchar,
        position integer
      );
    SQL

    # card_sets
    sqlite_db.execute <<-SQL
      CREATE TABLE card_sets (
        id text PRIMARY KEY,
        name text NOT NULL,
        date_release date,
        size integer,
        card_cycle_id text,
        card_set_type_id text,
        position integer,
        created_at datetime NOT NULL,
        updated_at datetime NOT NULL,
        legacy_code varchar,
        released_by varchar
      );
    SQL

    # card_types
    sqlite_db.execute <<-SQL
      CREATE TABLE card_types (
        id text PRIMARY KEY,
        name text NOT NULL,
        created_at datetime NOT NULL,
        updated_at datetime NOT NULL,
        side_id varchar
      );
    SQL

    # card_subtypes
    sqlite_db.execute <<-SQL
      CREATE TABLE card_subtypes (
        id text PRIMARY KEY,
        name text NOT NULL,
        created_at datetime NOT NULL,
        updated_at datetime NOT NULL
      );
    SQL

    puts 'Copying data...'

    # Copy data
    [Side, Faction, CardCycle, CardSet, CardType, CardSubtype].each do |model|
      puts "Copying #{model.name}..."
      table_name = model.table_name
      columns = model.column_names
      column_list = columns.join(', ')
      placeholders = (['?'] * columns.size).join(', ')

      insert_sql = "INSERT INTO #{table_name} (#{column_list}) VALUES (#{placeholders})"

      model.find_each do |record|
        values = columns.map { |col| record[col] }
        # Convert values for sqlite
        values = values.map do |v|
          if v == true
            1
          elsif v == false
            0
          elsif v.respond_to?(:iso8601)
            v.iso8601
          else
            v
          end
        end

        sqlite_db.execute(insert_sql, values)
      end
    end

    puts 'Done.'
  end
end
