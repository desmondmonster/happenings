# Happenings

A light framework for building and publishing domain events.

## Installation

Add this line to your application's Gemfile:

    gem 'happenings'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install happenings

## Usage

Start by creating a Plain Old Ruby Object for your domain event and including a Happening Event.
You'll want to declare an initialize method that sets up any needed variables.  Then, implement
a `#strategy` method and add your business logic there.  This method will be called when your
Happening Event is run.

```
class ResetPasswordEvent
  include Happening::Event

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

Run the event using the `#run` method as follows:

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

`#run!` will return Boolean `true` or `false` depending on the outcome of your strategy.
`#strategy` must return with `#success!` or `#failure!` or a `Happening::OutcomeError` will
be raised.

## Success, failure
`#success!` and `#failure!` will set a `succeeded?` attribute and set optional keys for 
`message` and `reason` attributes.  `message` is meant for human-readable messages, 
such as "Password reset failed", whereas `reason` is designed for machine-sortable
filtering, such as "confirmation\_mismatch".  An `elapsed_time` attribute is also recorded.


## Publishing
coming soon.


## Contributing

1. Fork it ( http://github.com/desmondmonster/happenings/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
