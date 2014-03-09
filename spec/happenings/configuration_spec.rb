require 'spec_helper'

describe 'config' do

  context 'with default settings' do
    it 'uses the library defaults' do
      expect(Happenings.config.logger).to be_a Logger
    end
  end

  context 'when settings are specified' do
    it 'uses the new settings' do
      require 'logger'

      class FooLogger < Logger; end

      Happenings.configure do |config|
        config.logger = FooLogger.new $stdout
      end

      expect(Happenings.config.logger).to be_a FooLogger
    end
  end

  context 'when random settings are specified' do
    it 'stores them in the config' do
      Happenings.configure {|c| c.socks = 'pants'}
      expect(Happenings.config.socks).to eq 'pants'
    end
  end
end
