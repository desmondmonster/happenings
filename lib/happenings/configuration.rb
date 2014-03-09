module Happenings
  class Configuration
    require 'logger'

    def initialize
      set_default_attributes
    end

    def set_default_attributes
      self.logger = default_logger
      self.publisher = default_publisher
      self.app_name = nil
    end

    def method_missing method, *args
      if method =~ /=$/
        attribute = method.to_s.sub '=', ''
        self.class.instance_eval { attr_accessor attribute }
        self.send method, args.first
      else
        super
      end
    end


    private

    def default_logger
      Logger.new $stdout
    end

    def default_publisher
      NullPublisher
    end

    class NullPublisher
      def self.publish payload, options
        true
      end
    end
  end
end
