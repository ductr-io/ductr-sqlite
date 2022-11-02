# frozen_string_literal: true

module Rocket
  module SQLite
    #
    # A source control that allows to select a big number of rows by relying on pagination, registered as `:paginated`.
    # Accept the `:page_size` option, default value is 10 000.
    #
    #   source :some_sqlite_database, :paginated, page_size: 4
    #   def my_source(db, offset, limit)
    #     db[:items].offset(offset).limit(limit)
    #   end
    #
    # Ensure to not select more rows than the configured page size,
    # otherwise it will raise an `InconsistentPaginationError`.
    #
    class PaginatedSource < Rocket::ETL::PaginatedSource
      Adapter.source_registry.add(self, as: :paginated)

      #
      # Calls the job's method and iterate on the query result.
      # Returns true if the page is full, false otherwise.
      #
      # @yield The each block
      #
      # @raise [InconsistentPaginationError] When the query return more rows than the page size
      # @return [Boolean] True if the page is full, false otherwise.
      #
      def each_page(&)
        rows_count = 0

        call_method(adapter.db, @offset, page_size).each do |row|
          yield(row)
          rows_count += 1
        end

        if rows_count > page_size
          raise InconsistentPaginationError,
                "The query returned #{rows_count} rows but the page size is #{page_size} rows"
        end

        rows_count == page_size
      end
    end
  end
end
