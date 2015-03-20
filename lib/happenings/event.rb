module Happenings

  class OutcomeError < StandardError; end

  module Event
    module ClassMethods
      def run! *args
        new(*args).tap &:run!
      end
    end

    def self.included base
      base.extend ClassMethods
    end

    attr_reader :duration, :message, :reason, :succeeded

    def run!
      time do
        strategy
      end

      raise OutcomeError.new "no outcome specified for #{event_name}" if no_outcome_specified?

      publish

      succeeded?
    end

    def strategy
      success!
    end

    def success! options = {}
      result true, options
    end

    def failure! options = {}
      result false, options
    end

    def succeeded?
      succeeded
    end

    def payload
      {}
    end

    def routing_key
      [event_name, outcome].compact.join '.'
    end


    private

    def result succeeded, options
      @succeeded = succeeded
      @message = options[:message]
      @reason = options[:reason]
    end

    def event_name
      self.class.to_s
    end

    def publish
      Happenings.config.publisher.publish additional_info.merge(payload), properties
    end

    def properties
      { message_id: SecureRandom.uuid,
        routing_key: routing_key,
        timestamp: Time.now.to_i }
    end

    def additional_info
      { event: event_name,
        reason: reason,
        message: message,
        succeeded: succeeded,
        duration: formatted_duration }
    end

    def outcome
      succeeded? ? 'success' : 'failure'
    end

    def no_outcome_specified?
      succeeded.nil?
    end

    def formatted_duration
      "%.6f" % @duration
    end

    def time
      initial_time = Time.now.to_f
      yield
      @duration = Time.now.to_f - initial_time
    end
  end
end
