# frozen_string_literal: true

module Rocket
  module SQLite
    #
    # A lookup control that execute the query for a bunch of rows, registered as `:buffered`.
    # Accept the `:buffer_size` option, default value is 10 000.
    # You have to implement your own row matching logic:
    #
    # ```ruby
    # lookup :some_sqlite_database, :buffered, buffer_size: 42
    # def my_lookup(db, buffer, &)
    #   ids = buffer.map {|row| row[:id]}
    #   db[:items].where(item: ids).each do |row|
    #     match = buffer.find { |r| r[:id] == row[:item] }
    #
    #     next yield(row) unless match
    #
    #     yield(row.merge match)
    #   end
    # end
    # ```
    #
    class BufferedLookup < Rocket::ETL::BufferedTransform
      Adapter.lookup_registry.add(self, as: :buffered)

      #
      # Opens the database if needed, calls the job's method and pass the each block to it.
      #
      # @yield The each block
      #
      # @return [void]
      #
      def on_flush(&)
        adapter.open! unless adapter.db

        call_method(adapter.db, buffer, &)
      end
    end
  end
end
