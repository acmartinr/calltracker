class CampaignsController < ApplicationController
  
  def index
  end
  
  def new
    @campaign = current_user.campaigns.new
  end
  
  def create
    vertical = current_user.verticals.find_by_id(params['campaign']['vertical_id'])
    respond_to do |format|
      if vertical
        @campaign = vertical.campaigns.build(campaign_params)
        if @campaign.save
          format.js { flash[:notice] = 'The destination has been added.' }
        else
          @error = true
          format.js { flash[:error] = @campaign.errors }
        end
      else
        @error = true
        @campaign = Campaign.new
        @campaign.errors.add(:vertical_id, 'must be selected')
        format.js { flash[:error] = @campaign.errors }
      end
    end
    
    if params[:campaign][:campaign_type] == 'buyer'
      buyer_password = SecureRandom.urlsafe_base64(10)
      buyer = User.create(
        name: 'Burk Morrison',
        email: params['buyer_email'].downcase,
        password: buyer_password,
        password_confirmation: buyer_password,
        master_user_id: current_user.id,
        buyer_campaign_id: campaign.id,
        buyer: true
      )
      buyer.password_reset_sent_at = Time.zone.now
      if buyer.save
        flash[:alert] = "Your buyer has been sent a confirmation email with their new account password." if UserMailer.email_buyer_confirmation(buyer).deliver
      else
        # If buyer fails model validation:
        buyer.errors.full_messages.each do |message|
          flash[:alert] = message
        end
      end
    end
  end
  
  def edit
    @campaign = Campaign.find(params[:id])
  end
  
  def update
    @campaign = Campaign.find(params[:id])
    @campaign.update_attributes(campaign_params)
    
    # Special redirects
    redirect_to dashboard_url, button: 'destinations' if params[:campaign].keys.count == 1 && params[:campaign].has_key?('active')
  end
  
  def destroy
    campaign = Campaign.find(params[:id])
    campaign.destroy
  end
	
	def contact_history
	  campaign = Campaign.find(params[:id])
	  respond_to do |format|
	    format.html
	    format.csv { send_data campaign.to_csv(campaign) }
	  end
	end
  
  private
  
  def campaign_params
    params.require(:campaign).permit(:name, :vertical_id, :campaign_type, :client_did, :schedule, :order_total, :daily_call_limit, :concurrent_call_limit, :buyer_balance, :buffer, :lead_cost, :funnel_ids, :active, :schedule_start, :schedule_end, blocked_states: [])
  end
end
