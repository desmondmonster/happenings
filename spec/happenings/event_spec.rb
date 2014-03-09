require 'spec_helper'

describe 'a happening event' do

  let(:event) { Event.new }

  describe '#run!' do
    context 'when no result action is called' do
      before { class Event; def strategy; end; end }

      it 'raises an exception' do
        expect {event.run!}.to raise_error Happenings::OutcomeError
      end
    end

    context 'when the strategy is successful' do
      before do
        class Event
          def strategy
            success! message: 'it worked'
          end
        end
      end

      it 'returns true' do
        expect(event.run!).to be
        expect(event).to be_succeeded
      end

      it 'records the elapsed time of the run' do
        event.run!
        expect(event.elapsed_time).to be > 0.0
      end

      it 'sets the message' do
        event.run!
        expect(event.message).to eq 'it worked'
      end
    end

    context 'when the strategy is unsuccessful' do
      before do
        class Event
          def strategy
            failure! message: 'it did not work'
          end
        end
      end

      it 'returns false' do
        expect(event.run!).not_to be
        expect(event).not_to be_succeeded
      end

      it 'records the elapsed time of the run' do
        event.run!
        expect(event.elapsed_time).to be > 0.0
      end

      it 'sets the message' do
        event.run!
        expect(event.message).to eq 'it did not work'
      end
    end
  end
end
