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

      it 'records the duration of the run' do
        event.run!
        expect(event.duration).to be > 0.0
      end

      it 'sets the message' do
        event.run!
        expect(event.message).to eq 'it worked'
      end

      it 'publishes the event' do
        Happenings.config.publisher.should_receive :publish
        event.run!
      end
    end

    context 'when the strategy is unsuccessful' do
      before do
        class Event
          def strategy
            failure! message: 'it did not work', reason: :you_broke_it
          end
        end
      end

      it 'returns false' do
        expect(event.run!).not_to be
        expect(event).not_to be_succeeded
      end

      it 'records the duration of the run' do
        event.run!
        expect(event.duration).to be > 0.0
      end

      it 'sets the message' do
        event.run!
        expect(event.message).to eq 'it did not work'
      end

      it 'publishes the event' do
        Happenings.config.publisher.should_receive :publish
        event.run!
      end
    end
  end

  describe 'event publishing' do
    let(:user) { User.new }
    let(:password) { 'password' }
    let(:payload) do
      { user: { id: 2 },
        event: 'reset_password_event',
        reason: nil,
        message: message,
        succeeded: succeeded }
    end
    let(:properties) { { routing_key: "reset_password_event.#{outcome}" } }

    context 'when the strategy is successful' do
      let(:confirmation) { password }
      let(:succeeded) { true }
      let(:message) { 'Password reset successfully' }
      let(:outcome) { 'success' }

      it 'publishes the event' do
        Happenings.config.publisher.should_receive(:publish)
          .with(hash_including(:duration, payload), hash_including(:message_id, :timestamp, properties))

        ResetPasswordEvent.new(user, password, confirmation).run!
      end
    end

    context 'when the strategy is unsuccessful' do
      let(:confirmation) { 'not the password' }
      let(:succeeded) { false }
      let(:message) { 'Password must match confirmation' }
      let(:outcome) { 'failure' }

      it 'publishes the event' do
        Happenings.config.publisher.should_receive(:publish)
          .with(hash_including(:duration, payload), hash_including(:message_id, :timestamp, properties))

        ResetPasswordEvent.new(user, password, confirmation).run!
      end
    end
  end
end
