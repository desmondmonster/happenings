require 'rails/generators'

module Happenings
  class EventGenerator < Rails::Generators::Base
    desc 'create a skeleton event and spec'

    argument :event_name, type: :string, desc: 'Name of event to generate', required: true

    def self.source_root
      @source_root ||= File.join(File.dirname(__FILE__), 'templates')
    end

    def create_event_file
      template 'new_event.erb', "#{Happenings.config.event_location}/#{event_name.underscore}.rb"
    end
  end

end
