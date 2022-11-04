# frozen_string_literal: true

module Ductr
  module SQLite
    #
    # A trigger based on the RufusTrigger, runs the PollingHandler at the given timing.
    # The handler calls the scheduler's method with a block which compares the yield result with the previous one.
    # If they are different, yield returns true:
    #
    #   trigger :my_database, :polling, interval: "1min"
    #   def check_timestamp(db) # will perform MyJob if the name have changed
    #     return unless yield(db[:items].select(:name).first)
    #
    #     MyJob.perform_later
    #   end
    #
    class PollingTrigger < Ductr::RufusTrigger
      Adapter.trigger_registry.add(self, as: :polling)

      #
      # Closes the connection if the scheduler is stopped.
      #
      # @return [void]
      #
      def stop
        super
        adapter.close!
      end

      private

      #
      # Returns a callable object, allowing rufus-scheduler to call it.
      #
      # @param [Ductr::Scheduler] scheduler The scheduler instance
      # @param [Symbol] method_name The scheduler's method name
      # @param [Hash] ** The option passed to the trigger annotation
      #
      # @return [#call] A callable object
      #
      def callable(scheduler, method_name, **)
        PollingHandler.new(scheduler, method_name, adapter)
      end

      #
      # Returns the adapter corresponding to the given adapter_name.
      #
      # @return [Ductr::Adapter] The trigger's adapter instance
      #
      def adapter
        Ductr.config.adapter(@adapter_name)
      end
    end
  end
end
