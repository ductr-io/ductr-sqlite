# frozen_string_literal: true

module Rocket
  module SQLite
    #
    # The SQLite adapter class implement the required #open! and #close! methods to handle the database connection.
    # The adapter is registered as `:sqlite` to use it, add `adapter: sqlite` to the YAML configuration e.g.:
    #
    # ```yml
    # # config/development.yml
    # adapters:
    #   some_sqlite_database:
    #     adapter: "sqlite"
    #     database: "example.db"
    # ```
    #
    class Adapter < Rocket::Adapter
      Rocket.adapter_registry.add(self, as: :sqlite)

      # @return [Sequel::Database, nil] The database connection instance
      attr_reader :db

      #
      # Opens the database connection with the adapter's configuration.
      #
      # @return [Sequel::Database] The database connection instance
      #
      def open!
        @db = Sequel.sqlite(**config)
      end

      #
      # Closes the database connection.
      # In the specific case of SQLite, we just destroy the connection instance.
      #
      # @return [void]
      #
      def close!
        @db = nil
      end
    end
  end
end
