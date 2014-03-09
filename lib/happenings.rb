
require 'happenings/version'
require_relative 'happenings/configuration'
require_relative 'happenings/base'


module Happenings

  def self.configure
    yield configuration if block_given?
  end

  def self.configuration
    @@configuration ||= Configuration.new
  end
end
