# frozen_string_literal: true

module Rocket
  module SQLite
    #
    # A destination control that accumulates rows in a buffer to write them by batch, registered as `:buffered`.
    # Accept the `:buffer_size` option, default value is 10 000:
    #
    #   destination :some_sqlite_database, :buffered, buffer_size: 42
    #   def my_destination(buffer, db)
    #     db[:items].multi_insert(buffer)
    #   end
    #
    # @see more Rocket::ETL::BufferedDestination
    #
    class BufferedDestination < Rocket::ETL::BufferedDestination
      Adapter.destination_registry.add(self, as: :buffered)

      #
      # Open the database if needed and call the job's method to run the query.
      #
      # @return [void]
      #
      def on_flush
        adapter.open! unless adapter.db

        call_method(buffer, adapter.db)
      end
    end
  end
end
