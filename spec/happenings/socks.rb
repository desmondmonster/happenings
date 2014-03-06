require 'spec_helper'


describe Happenings::Base do

  let(:event) { Event.new }

  describe '#run!' do
    it 'should be overriden' do
      expect(event.run!).to raise_error
    end
  end
end
