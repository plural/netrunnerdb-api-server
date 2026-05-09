# frozen_string_literal: true

namespace :sqlite do
  desc 'Create a sqlite3 database for configured tables.'
  task :create, [:upload] => :environment do |_, args|
    require 'sqlite3'
    require 'json'
    require 'zlib'
    require 'aws-sdk-s3'

    upload = ['true', true].include?(args[:upload])

    if upload
      missing_vars = []
      %w[DO_SPACES_KEY DO_SPACES_SECRET DO_SPACES_ENDPOINT DO_SPACES_REGION DO_SPACES_BUCKET
         DO_SPACES_FOLDER DB_URL_PREFIX].each do |var|
        missing_vars << var if ENV[var].nil? || ENV[var].strip.empty?
      end

      if missing_vars.any?
        missing_vars.each do |var|
          puts "Missing required environment variable for upload: #{var}"
        end
        puts 'Upload requested but required environment variables are missing. Exiting.'
        exit 1
      end
    end

    target_models = [
      Card,
      CardCycle,
      CardPool,
      CardPoolCardCycle,
      CardPoolCardSet,
      CardSet,
      CardSetType,
      CardSubtype,
      CardType,
      Faction,
      Format,
      Illustrator,
      Printing,
      Restriction,
      RestrictionCardBanned,
      RestrictionCardGlobalPenalty,
      RestrictionCardPoints,
      RestrictionCardRestricted,
      RestrictionCardSubtypeBanned,
      RestrictionCardUniversalFactionCost,
      Side,
      Snapshot
    ]

    puts 'Loading model table definitions and data from Postgres...'
    schema_definitions = {}
    data_cache = {}

    target_models.each do |model|
      # Parse schema definitions
      schema_definitions[model] = model.columns.map do |col|
        type = col.type
        options = {
          limit: col.limit,
          precision: col.precision,
          scale: col.scale,
          default: col.default,
          null: col.null
        }

        if col.respond_to?(:array) && col.array
          type = :text
          options[:limit] = nil
          options[:precision] = nil
          options[:scale] = nil
        end

        {
          name: col.name,
          type: type,
          options: options
        }
      end

      data_cache[model] = model.all.map(&:attributes)
      puts "Loaded #{data_cache[model].size} records for #{model.name}"
    end

    db_file = Rails.root.join('db', 'netrunnerdb.sqlite3')
    FileUtils.rm_f(db_file)

    pg_config = ActiveRecord::Base.connection_db_config

    puts "Creating tables in SQLite db at #{db_file}..."
    ActiveRecord::Base.establish_connection(
      adapter: 'sqlite3',
      database: db_file.to_s
    )
    connection = ActiveRecord::Base.connection

    puts 'Creating tables...'
    target_models.each do |model|
      table_name = model.table_name
      columns = schema_definitions[model]
      primary_key = model.primary_key

      puts "Creating table #{table_name}..."
      connection.create_table(table_name, id: false, force: true) do |t|
        columns.each do |col_def|
          options = col_def[:options]
          options[:primary_key] = true if col_def[:name] == primary_key
          t.column col_def[:name], col_def[:type], **options
        end
      end
    end

    puts 'Inserting data into SQLite db...'
    target_models.each do |model|
      rows = data_cache[model]
      next if rows.empty?

      # Convert array values to JSON strings for SQLite compatibility
      rows.each do |row|
        row.each do |key, value|
          row[key] = value.to_json if value.is_a?(Array)
        end
      end

      # Force a reload of backing model information to force using new SQLite schema.
      model.reset_column_information
      puts "  Inserting #{rows.size} records into #{model.table_name}..."
      rows.each_slice(100) { |batch| model.insert_all(batch) } # rubocop:disable Rails/SkipsModelValidations
    end

    puts 'Verifying data...'
    target_models.each do |model|
      puts "  Verifying #{model.name}..."
      original_records = data_cache[model]

      if model.primary_key
        verify_by_primary_key(original_records, model)
      else
        verify_without_primary_key(original_records, model)
      end
    end

    puts 'Restoring Postgres connection...'
    ActiveRecord::Base.establish_connection(pg_config)

    db_details = compress_db(db_file)

    publish_db(db_details) if upload

    puts 'Done.'
  end

  def verify_by_primary_key(original_records, model)
    original_records.each do |original_attrs|
      pk = model.primary_key
      id = original_attrs[pk]

      # Reload explicitly from the new connection
      sqlite_record = model.find_by(pk => id)

      unless sqlite_record
        puts "MISSING RECORD: #{model.name} #{id}"
        next
      end

      original_attrs.each do |col, original_val|
        sqlite_val = sqlite_record[col]

        # Simple normalization for comparison
        match = if original_val.is_a?(Time) && sqlite_val.is_a?(Time)
                  # Compare up to seconds to allow for precision loss
                  original_val.to_i == sqlite_val.to_i
                else
                  lhs = original_val
                  rhs = sqlite_val

                  # Handle Array comparison (Postgres Array vs SQLite JSON/String)
                  if lhs.is_a?(Array)
                    rhs = begin
                      JSON.parse(rhs)
                    rescue StandardError
                      rhs
                    end

                    # Sort values first if both are arrays
                    if rhs.is_a?(Array)
                      lhs = lhs.sort
                      rhs = rhs.sort
                    end
                  end

                  lhs == rhs
                end

        unless match
          puts "MISMATCH: #{model.name} #{id} [#{col}] - PG: #{original_val.inspect} vs SQL: #{sqlite_val.inspect}"
        end
      end
    end
  end

  def verify_without_primary_key(original_records, model)
    # Verification without Primary Key (Full Table Sort & Compare)
    puts "    No primary key for #{model.name}, performing full table comparison..."

    # Helper to normalize records for comparison
    normalize_for_sort = lambda do |record|
      # Transform hash values for consistent sorting
      record.transform_values do |val|
        case val
        when Time
          val.to_i
        when String
          if val.strip.start_with?('[')
            begin
              JSON.parse(val)
            rescue StandardError
              val
            end
          else
            val
          end
        when Array
          val.sort
        else
          val
        end
      end
    end

    # Capture SQLite records
    sqlite_records = model.all.map(&:attributes)

    if original_records.size != sqlite_records.size
      puts "COUNT MISMATCH: PG: #{original_records.size} vs SQL: #{sqlite_records.size}"
    end

    # Sort key generator: use JSON representation to ensure deterministic order
    sort_key_gen = ->(r) { r.sort.to_h.to_json }

    normalized_original = original_records.map(&normalize_for_sort).sort_by(&sort_key_gen)
    normalized_sqlite = sqlite_records.map(&normalize_for_sort).sort_by(&sort_key_gen)

    normalized_original.each_with_index do |orig_record, idx|
      sqlite_record = normalized_sqlite[idx]

      next unless orig_record != sqlite_record

      puts "    MISMATCH at sorted index #{idx}:"
      puts "      PG: #{orig_record.inspect}"
      puts "      SQL: #{sqlite_record.inspect}"

      orig_record.each do |k, v|
        puts "    Diff [#{k}]: #{v.inspect} != #{sqlite_record[k].inspect}" if sqlite_record[k] != v
      end
    end
  end

  def compress_db(db_file)
    puts 'Compressing database...'
    r = { db_file: db_file, time: Time.zone.now }
    r[:gzip_path] = "#{db_file}.#{r[:time].to_i}.gz"

    Zlib::GzipWriter.open(r[:gzip_path]) do |gz|
      File.open(db_file.to_s, 'rb') do |file|
        while (chunk = file.read(1024 * 1024))
          gz.write(chunk)
        end
      end
    end
    puts "Database compressed to #{r[:gzip_path]}"

    r
  end

  def publish_db(output_details)
    file_path = output_details[:gzip_path]
    puts "Uploading #{file_path} to Digital Ocean Spaces..."
    s3_client = Aws::S3::Client.new(
      access_key_id: ENV.fetch('DO_SPACES_KEY'),
      secret_access_key: ENV.fetch('DO_SPACES_SECRET'),
      endpoint: ENV.fetch('DO_SPACES_ENDPOINT'),
      region: ENV.fetch('DO_SPACES_REGION')
    )

    file_path = File.join(ENV.fetch('DO_SPACES_FOLDER'), File.basename(file_path))

    File.open(output_details[:db_file], 'rb') do |file|
      s3_client.put_object(
        bucket: ENV.fetch('DO_SPACES_BUCKET'),
        key: file_path,
        body: file,
        acl: 'public-read',
        content_type: 'application/gzip'
      )
    end

    published_db = PublishedDatabase.create!(
      url: "#{ENV.fetch('DB_URL_PREFIX').gsub(%r{/$}, '')}/#{file_path}",
      created_at: output_details[:time],
      updated_at: output_details[:time]
    )
    puts "Successfully #{file_path} uploaded to spaces: #{published_db.url}"
  end
end
