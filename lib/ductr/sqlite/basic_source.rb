# frozen_string_literal: true

module Ductr
  module SQLite
    #
    # A source control that yields rows one by one, registered as `:basic`:
    #
    #   source :some_sqlite_database, :basic
    #   def select_some_stuff(db)
    #     db[:items].limit(42)
    #   end
    #
    # Do not try to select a large number of rows, as they will all be loaded into memory.
    #
    class BasicSource < Ductr::ETL::Source
      Adapter.source_registry.add(self, as: :basic)

      #
      # Opens the database, calls the job's method and iterate over the query results.
      #
      # @yield The each block
      #
      # @return [void]
      #
      def each(&)
        call_method(adapter.db).each(&)
      end
    end
  end
end
