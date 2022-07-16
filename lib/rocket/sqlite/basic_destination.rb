# frozen_string_literal: true

module Rocket
  module SQLite
    #
    # A destination control that write rows one by one, registered as `:basic`:
    #
    # ```ruby
    # destination :some_sqlite_database, :basic
    # def my_destination(row, db)
    #   db[:items].insert(row)
    # end
    # ```
    #
    class BasicDestination < Rocket::ETL::Destination
      Adapter.destination_registry.add(self, as: :basic)

      #
      # Opens the database if needed and call the job's method to insert one row at time.
      #
      # @param [Hash<Symbol, Object>] row The row to insert, preferably a Hash
      #
      # @return [void]
      #
      def write(row)
        adapter.open! unless adapter.db

        call_method(row, adapter.db)
      end
    end
  end
end
