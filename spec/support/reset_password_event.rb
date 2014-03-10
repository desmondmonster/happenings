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

