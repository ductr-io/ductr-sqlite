# frozen_string_literal: true

module Rocket
  module SQLite
    #
    # The rufus-scheduler handler class.
    # @see https://github.com/jmettraux/rufus-scheduler#scheduling-handler-instances
    #   For further information
    #
    class PollingHandler
      #
      # Creates the handler based on the given scheduler, its method name and the trigger's adapter instance.
      #
      # @param [Rocket::Scheduler] scheduler The scheduler instance
      # @param [Symbol] method_name The scheduler's method name
      # @param [Rocket::Adapter] adapter The trigger's adapter
      #
      def initialize(scheduler, method_name, adapter)
        @scheduler = scheduler
        @method_name = method_name
        @adapter = adapter
        @last_triggering_key = nil
      end

      #
      # The callable method used by the trigger, actually calls the scheduler's method.
      #
      # @return [void]
      #
      def call
        @adapter.open do |db|
          @scheduler.send(@method_name, db) do |triggering_key|
            return false if triggering_key == @last_triggering_key

            @last_triggering_key = triggering_key
            true
          end
        end
      end
    end
  end
end
