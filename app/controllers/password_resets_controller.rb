class PasswordResetsController < ApplicationController
  before_action :disable_navbar, only: [ :new, :edit ]
  
  def new
  end
  
  def create
    user = User.find_by_email(params[:reset][:email])
    user.send_password_reset if user
    redirect_to root_url, notice: 'Email sent with password reset instructions.'
  end
  
  def edit
    @user = User.find_by(password_reset_token: params[:id])
    redirect_to root_url if @user.blank?
  end
  
  def update
    user = User.find_by(password_reset_token: params[:reset][:reset_token])
    unless user.blank?
      if user.password_reset_sent_at < 2.hours.ago
        redirect_to login_url, alert: 'Password reset has expired.'
      elsif user.update_attributes(params.require(:reset).permit(:password, :password_confirmation))
        user.update_attribute(:email_confirmed, true)
        user.regenerate_password_reset_token
        redirect_to login_url, alert: 'Your password has been reset.'
      else
        redirect_to passwordreset_url(id: user.password_reset_token), alert: ' '
      end
    else
      redirect_to root_url
    end
  end
end
