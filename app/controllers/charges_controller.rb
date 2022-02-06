class ChargesController < ApplicationController
  def new
  end

  def create
    if params.has_key?(:amount)
      session[:charge_amount] = (params[:amount].to_i * 100)
      Rails.logger.debug "Amount hit: #{session[:charge_amount]}."
      respond_to do |format|
        format.js
      end
    else
      customer = Stripe::Customer.create(
        :email => params[:stripeEmail],
        :source  => params[:stripeToken]
      )

      charge = Stripe::Charge.create(
        :customer    => customer.id,
        :amount      => session[:charge_amount],
        :description => current_user.email,
        :currency    => 'usd'
      )
      
      convert_cents = (session[:charge_amount] / 100).to_d
      current_user.charges.create(amount: convert_cents, stripe_token: params[:stripeToken])
      current_user.increment!(:balance, by = convert_cents)
			current_user.update_attribute(:send_billing_reminder, true) unless current_user.send_billing_reminder?
      
      redirect_to '/dashboard?button=payment'
    end

  rescue Stripe::CardError => e
    flash[:error] = e.message
    redirect_to '/dashboard?button=charges'
  end
end
