# frozen_string_literal: true

module Rocket
  module SQLite
    #
    # A source control that yields rows one by one, registered as `:basic`:
    #
    # ```ruby
    # source :some_sqlite_database, :basic
    # def select_some_stuff(db)
    #   db[:items].limit(42)
    # end
    # ```
    #
    # Do not try to select a large number of rows, as they will all be loaded into memory.
    #
    class BasicSource < Rocket::ETL::Source
      Adapter.source_registry.add(self, as: :basic)

      #
      # Opens the database, calls the job's method and iterate over the query results.
      #
      # @yield The each block
      #
      # @return [void]
      #
      def each(&)
        adapter.open do |db|
          call_method(db).each(&)
        end
      end
    end
  end
end
