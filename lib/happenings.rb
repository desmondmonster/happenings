require "happenings/version"

module Happenings
  module Base

    def run!
      raise 'override me!'
    end
  end
end
