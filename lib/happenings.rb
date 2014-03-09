
require 'happenings/version'
require_relative 'happenings/config'
require_relative 'happenings/base'


module Happenings

  def self.configure
    yield config if block_given?
  end

  def self.config
    @@config ||= Config.new
  end
end
