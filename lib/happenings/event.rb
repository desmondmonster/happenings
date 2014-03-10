module Happenings

  class OutcomeError < StandardError; end

  module Event

    attr_reader :elapsed_time, :message, :reason, :succeeded

    def run!
      time do
        strategy
      end

      if succeeded.nil?
        raise OutcomeError.new 'no outcome specified'
      end

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
      [app_name, event_name, outcome].compact.join '.'
    end


    private

    def result succeeded, options
      @succeeded = succeeded
      @message = options[:message]
      @reason = options[:reason]

      publish

      succeeded
    end

    def app_name
      Happenings.config.app_name
    end

    def event_name
      self.class.to_s.split('::').last.downcase
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
        succeeded: succeeded }
    end

    def outcome
      succeeded? ? 'success' : 'failure'
    end

    def time
      initial_time = Time.now.to_f
      yield
      @elapsed_time = Time.now.to_f - initial_time
    end
  end
end
