class DashboardsController < ApplicationController
  #before_action :disable_navbar, only: [:show]
  before_action :authorize, only: [:show]
  
  def show
    user = current_user
    if user.buyer?
      @active = 'buyers'
      @campaign = Campaign.find_by(id: current_user.buyer_campaign_id)
    else
      @active = params[:button]
      @active = 'destinations' if @active.blank?
			
			# Redirect to payment screen if zero balance
			if user.balance < 0.to_d
				@active = 'charges'
				flash[:error] = 'Please fund your account.'
			end
    end
  end
  
  def filter_dids
    funnel = Funnel.find_by_id(params[:did_filter][:funnel_id])
    vertical = Vertical.find_by_id(params[:did_filter][:vertical_id])
    campaign = Campaign.find_by_id(params[:did_filter][:campaign_id])
    @dids = ''
    
    if funnel
      @dids = funnel.dids
    elsif vertical
      funnels = current_user.funnels
      vertical_funnels = funnels.where(vertical_id: vertical.id)
      @dids = Did.where(funnel_id: vertical_funnels.ids)
    elsif campaign
      funnels = campaign.funnels
      @dids = Did.where(funnel_id: funnels.ids)
    end
    
    Rails.logger.debug(@dids)
    
    respond_to do |format|
      format.js { @dids }
    end
  end
  
  def reassign_dids
    funnel = Funnel.find_by_id(params[:reassign_dids][:funnel_id])
    vertical = Vertical.find_by_id(params[:reassign_dids][:vertical_id])
    campaign = Campaign.find_by_id(params[:reassign_dids][:campaign_id])
    dids = Did.where(id: params[:reassign_dids][:dids])
    change_counter = 0
    
    dids.each do |did|
      # Handle funnel mass reassignment
      if did.funnel.id != funnel.id
        unless funnel.blank?
          did.update_attribute(:funnel_id, funnel.id) 
          change_counter += 1
        end
      end
      
      respond_to do |format|
        change_counter = 'No' if change_counter == 0
        format.js { flash[:notice] = "#{change_counter} DIDs edited." }
      end
    end
  end
  
  def campaign_active
  end
end
