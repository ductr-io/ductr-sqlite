# frozen_string_literal: true

module Ductr
  module SQLite
    #
    # A lookup control that execute one query per row, registered as `:basic`.
    # The job's method must return a row which will merged with the current row:
    #
    #   lookup :some_sqlite_database, :basic
    #   def my_lookup(row, db)
    #     db[:items_bis].where(item: row[:id]).limit(1)
    #   end
    #
    # As the control merge the looked up row with the current row,
    # ensure that column names are different or they will be overwritten.
    #
    # If the lookup returns a falsy value, nothing won't be merged with the current row.
    #
    class BasicLookup < Ductr::ETL::Transform
      Adapter.lookup_registry.add(self, as: :basic)

      #
      # Calls the job's method to merge its result with the current row.
      #
      # @param [Hash<Symbol, Object>] row The current row, preferably a Hash
      #
      # @return [Hash<Symbol, Object>] The row merged with looked up row or the untouched row if nothing was found
      #
      def process(row)
        matching_row = call_method(row, adapter.db).first
        return row unless matching_row

        row.merge matching_row
      end
    end
  end
end
