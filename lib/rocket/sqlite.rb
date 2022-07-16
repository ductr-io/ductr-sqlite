# frozen_string_literal: true

require "rocket"
require "sequel"

Dir[File.join(__dir__, "sqlite", "*.rb")].each { |file| require file }

# :nodoc:
module Rocket
  #
  # ## SQLite adapter for Rocket ETL
  # This gem provides useful controls to operate Rocket ETL with SQLite databases.
  #
  # To get details about the database connection handling, checkout the {Rocket::SQLite::Adapter} class.
  #
  # ### Sources
  # - {Rocket::SQLite::BasicSource} Yields rows one by one.
  # - {Rocket::SQLite::PaginatedSource} Allows to select a big number of rows by relying on pagination.
  #
  # ### Lookups
  # - {Rocket::SQLite::BasicLookup} Executes one query per row and merge the looked up row with the current row.
  # - {Rocket::SQLite::BufferedLookup} Executes one query for a bunch of rows and let you implement the matching logic.
  # - {Rocket::SQLite::MatchLookup} Executes one query for a bunch of rows and abstracts the matching logic.
  #
  # ### Destinations
  # - {Rocket::SQLite::BasicDestination} Writes rows one by one.
  # - {Rocket::SQLite::BufferedDestination} Accumulates rows in a buffer to write them by batch.
  # - {Rocket::SQLite::BufferedUpsertDestination} Accumulates rows in a buffer to upsert them by batch.
  #
  module SQLite; end
end
