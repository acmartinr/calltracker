class EmailConfirmationsController < ApplicationController
  def new
  end
  
  def create
    user = current_user
    UserMailer.email_confirmation(user).deliver
  end

  def update
    user = User.find_by(confirm_token: params[:id])
    unless user.blank?
      user.update_attribute(:email_confirmed, true)
      user.regenerate_confirm_token
      flash[:alert] = 'You have verified your email address!'
      redirect_to login_url
    else
      redirect_to root_url
    end
  end
end
