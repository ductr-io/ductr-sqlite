# frozen_string_literal: true

module Ductr
  module SQLite
    #
    # A destination control that write rows one by one, registered as `:basic`:
    #
    #   destination :some_sqlite_database, :basic
    #   def my_destination(db, row)
    #     db[:items].insert(row)
    #   end
    #
    class BasicDestination < Ductr::ETL::Destination
      Adapter.destination_registry.add(self, as: :basic)

      #
      # Opens the database if needed and call the job's method to insert one row at time.
      #
      # @param [Hash<Symbol, Object>] row The row to insert, preferably a Hash
      #
      # @return [void]
      #
      def write(row)
        call_method(adapter.db, row)
      end
    end
  end
end
