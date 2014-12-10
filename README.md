# Happenings

A light framework for building and publishing domain events.

## Installation

Add this line to your application's Gemfile:

    gem 'happenings'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install happenings

## Basic Usage

Start by creating a Plain Old Ruby Object for your domain event and including the `Happenings::Event` module.
You'll want to declare an initialize method that sets up any needed variables.  Then, implement
a `#strategy` method and add your business logic there.  This method will be called when your
Happening Event is run and returns a generic success by default.  `#strategy` must return with
`#success!` or `#failure!` or a `Happenings::OutcomeError` will be raised.

```
class ResetPasswordEvent
  include Happenings::Event

  def initialize user, new_password, new_password_confirmation
    @user = user
    @new_password = new_password
    @new_password_confirmation = new_password_confirmation
  end

  def strategy
    if @new_password == @new_password_confirmation
      @user.reset_password! @new_password
      success! message: 'Password reset successfully'
    else
      failure! message: 'Password must match confirmation'
    end
  end
end
```

Run the event using the `#run!` method as follows:

```
event = ResetPasswordEvent.new(user, 'secret_password', 'secret_password')
if event.run!
  # it worked, do something
  flash[:notice] = event.message
else
  # event failed for some reason
  flash[:error] = event.message
end
```

`#run!` will return Boolean `true` or `false` depending on the outcome of your strategy.  If you don't care about the outcome, you can use
the class method `.run!`, which takes the same arguments as `#new` runs the event, and returns the event.  This is useful if you don't expect
the event to fail or you want to handle errors some other way:

```
class AuthenticateUser
  include Happenings::Event

  attr_reader :user

  def initialize auth_token
    @auth_token = auth_token
  end

  def strategy
    if (@user = User.find_by_auth_token @auth_token)
      success!
    else
      failure! message: 'No user found'
    end
  end
end

class MyController
  def authenticate_user
    set_current_user or
      render status: 401, json: { 'you must be signed in to do that' } and return
  end

  def set_current_user
    @current_user = AuthenticateUser.run!(params[:auth_token]).user
  end
end
```

## Success, Failure
`#success!` and `#failure!` will set a `succeeded?` attribute and optional keys for 
`message` and `reason` attributes.  `message` is meant for human-readable messages, 
such as "Password reset failed", whereas `reason` is designed for machine-sortable
filtering, such as "confirmation\_mismatch".  A `duration` attribute is also recorded.


## Publishing
Happenings makes it easy to disseminate your business events to interested parties, such as
your analytics system, cache counters, or background workers.  Happenings will swallow the
events by default, but it's recommended that you set a publisher in the configuration (see below).
This publisher must respond to a `publish` method that accepts two arguments: the 
payload and a hash of additional info.  This arrangement is geared towards a message broker like
RabbitMQ, but you can certainly write your own wrapper for another messaging bus like Redis.

Publishing happens automatically when `#run!` is called, regardless of the strategy outcome.  The following methods are important:

`payload`: The main package of the event.  defaults to `{}`, but should
be overridden in your event to include useful info such as the user id, changed attributes, etc.

`routing_key`: The routable description of the event.  Defaults to `#{event_name}.#{outcome}`, where outcome is either 'success' or 'failure'.
You can override this to use your own routing scheme, but you'll probably just want to augment it by
calling `"#{super}.my.details.here"`.

`event_name`: A machine-filterable version of the event.  Defaults to the event's class name.  Override
this to use your own naming scheme.

Here's an expanded version of our Reset Password example above that includes publishing features:

```
class MyEventPublisher
  require 'bunny'

  def initialize
    @rabbitmq = Bunny.new
    @rabbitmq.start
    @rabbitmq_channel = @rabbitmq.create_channel
    @events_exchange = @rabbitmq_channel.topic 'events', durable: true
  end

  def publish message, properties
    @events_exchange.publish JSON.dump(message), properties
  end
end


Happenings.configure do |config|
  config.publisher = MyEventPublisher.new
end

class ResetPasswordEvent
  include Happenings::Event

  attr_reader :user, :new_password, :new_password_confirmation

  def initialize user, new_password, new_password_confirmation
    @user = user
    @new_password = new_password
    @new_password_confirmation = new_password_confirmation
  end

  def strategy
    ensure_passwords_match and
      reset_user_password
  end

  def payload
    { user: { id: user.id } }
  end


  private

  def reset_user_password
    user.reset_password! new_password
    success! message: 'Password reset successfully'
  end

  def ensure_passwords_match
    new_password == new_password_confirmation or
      failure! message: 'Password must match confirmation'
  end
end
```

If the event is successful, `MyEventPublisher#publish` will receive the following parameters:
```
message.inspect # => { user: { id: 2 },
                       event: 'ResetPasswordEvent',
                       reason: nil,
                       message: 'Password reset successfully',
                       duration: '0.0015',
                       succeeded: true }

properties.inspect # => { message_id: <SecureRandom.uuid>,
                          routing_key: 'ResetPasswordEvent.success',
                          timestamp: <Time.now.to_i> }
```
## Generating event templates

If you're using Rails, there's a convenient generator that will make a skeleton event file for you. Running
```
$ rails g happenings:event reset_password
```
will create `lib/events/reset_password.rb` with some basic event methods.  You can change where these files
are created by setting `Happenings.config.event_location = 'path/to/your/events'`


## Configuration
You can change the Happenings configuration by passing a block to the `.configure` method.
If you're using Happenings with Rails, a good place for this setup is in an
initializer such as `config/initializers/happenings.rb`:

```
Happenings.configure do |config|
  config.logger = your_logger # defaults to $stdout
  config.publisher = your_publisher # defaults to a NullPublisher
  config.socks = 'black socks' # add your own, be sure not to misspell a config!
  config.base_event_class = 'some_event_class' # for the generator, defaults to BasicEvent
  config.event_location = 'app/events' # where the generator stores the new files.  Defaults to 'lib/events'
end
```

## Contributing

1. Fork it ( http://github.com/desmondmonster/happenings/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
