class BackofficeController < ApplicationController
  http_basic_authenticate_with name: "Administrator", password: Rails.application.credentials.backoffice_password
  
  def index
    @users = User.all
		@global_billing = Global.where(name: 'default_billing_rate').first_or_create
		@global_local_did_price = Global.where(name: 'default_local_did_price').first_or_create
		@global_tfn_price = Global.where(name: 'default_tfn_price').first_or_create
		@billing_reminder = Global.where(name: 'billing_reminder').first_or_create
  end
  
  def update
    if params['global']
			global = Global.where(id: params['id'].to_i).first
      Global.update(params['id'].to_i, value: params['global']['value'])
      flash[:notice] = "#{global.name.humanize} updated."
		else
			@account = User.find(params[:account][:id])
			@account.update_attributes(account_params)
			flash[:notice] = "#{@account.email} updated."
    end
		@global_billing = Global.where(name: 'default_billing_rate').first_or_create
		@global_local_did_price = Global.where(name: 'default_local_did_price').first_or_create
		@global_tfn_price = Global.where(name: 'default_tfn_price').first_or_create
		@billing_reminder = Global.where(name: 'billing_reminder').first_or_create
  end
	
	def edit
		@account = User.find(params[:id])
	end
	
  private
  
  def account_params
    params.require(:account).permit(:name, :email, :balance, :billing_rate)
  end
end
