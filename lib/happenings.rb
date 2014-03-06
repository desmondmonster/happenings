
require 'happenings/version'
require_relative 'happenings/configuration'


module Happenings

  def self.configure
    yield configuration if block_given?
  end

  def self.configuration
    @@configuration ||= Configuration.new
  end

  module Base

    def run!
      raise 'override me!'
    end
  end
end
