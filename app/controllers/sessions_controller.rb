class SessionsController < ApplicationController
  include SessionsHelper
  
  def new
  end
  
  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      if user.email_confirmed?
        log_in(user)
        params[:session][:remember_me] == '1' ? remember(user) : forget(user)
        # Render their dashboard with a successful login:
        render js: "window.location = '#{dashboard_path}'"
      else
        flash[:alert] = 'Oops! Email has not yet been confirmed.'
      end
    else
      flash[:alert] = 'Oops! Incorrect email or password.'
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to welcome_url
  end 
end
