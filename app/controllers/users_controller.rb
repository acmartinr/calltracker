class UsersController < ApplicationController
  before_action :disable_navbar, only: [:new, :edit]
  before_action :authorize, only: [:show, :update, :edit]
  
  def new
  end

  def create
    @user = User.new(user_params)
  
    # Store all emails in lowercase to avoid duplicates and case-sensitive login errors:
    @user.email.downcase!
  
    if @user.save
      flash[:alert] = "Thanks! You've been sent an email." if UserMailer.email_confirmation(@user).deliver
    else
      # If user fails model validation - probably a bad password or duplicate email:
      @user.errors.full_messages.each do |message|
        flash[:alert] = message
      end
    end
  end
  
  def show
  end
  
  def destroy
  end

  private
  
  def user_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation)
  end
end
