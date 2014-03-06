module Happenings
  class Configuration
    require 'logger'

    def initialize
      set_default_attributes
    end

    def set_default_attributes
      self.logger = Logger.new $stdout
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
  end
end
