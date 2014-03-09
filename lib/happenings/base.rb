module Happenings

  class OutcomeError < StandardError; end

  module Base

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


    private

    def result succeeded, options
      @succeeded = succeeded
      @message = options[:message]
      @reason = options[:reason]
    end

    def outcome
      succeeded? ? 'success' : 'failure'
    end

    # def publish_event_to_exchange
      # RabbitmqWrapper.publish_event additional_info.merge(payload), properties
    # end

    def time
      initial_time = Time.now.to_f
      yield
      @elapsed_time = Time.now.to_f - initial_time
    end


  end
end
