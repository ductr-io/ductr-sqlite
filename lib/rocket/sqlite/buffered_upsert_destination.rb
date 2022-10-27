# frozen_string_literal: true

module Rocket
  module SQLite
    #
    # A destination control that accumulates rows in a buffer to upsert them by batch, registered as `:buffered_upsert`.
    # Accept the `:buffer_size` option, default value is 10 000:
    #
    #   destination :some_sqlite_database, :buffered_upsert, buffer_size: 42
    #   def my_destination(buffer, excluded, db)
    #     db[:items].insert_conflict(target: :id, update: excluded).multi_insert(buffer)
    #   end
    #
    # @see more Rocket::ETL::BufferedDestination
    #
    class BufferedUpsertDestination < Rocket::ETL::BufferedDestination
      Adapter.destination_registry.add(self, as: :buffered_upsert)

      #
      # Open the database if needed and call the job's method to run the query.
      #
      # @return [void]
      #
      def on_flush
        adapter.open! unless adapter.db

        call_method(buffer, excluded, adapter.db)
      end

      private

      #
      # Generate the excluded keys hash e.g.
      #
      # ```ruby
      # {a: Sequel[:excluded][:a]}
      # ```
      #
      # @return [Hash<Symbol, Sequel::SQL::QualifiedIdentifier>] The excluded keys hash
      #
      def excluded
        keys = buffer.first.keys

        excluded_keys = keys.map do |key|
          Sequel[:excluded][key]
        end

        keys.zip(excluded_keys).to_h
      end
    end
  end
end
