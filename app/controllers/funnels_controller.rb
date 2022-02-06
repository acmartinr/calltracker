class FunnelsController < ApplicationController
  
  def index
  end
  
  def new
    @funnel = current_user.funnels.new
  end
  
  def create
		logger.debug(current_user.inspect)
    @funnel = current_user.funnels.build(funnel_params)
		
    respond_to do |format|
      if @funnel.save
				if funnel_params['bulk_dids'].to_i > 0
					area_codes = ApplicationController.new.get_state_area_codes(funnel_params['selected_states'])
					area_codes = ['TFNS'] if funnel_params['toll_free'].to_i > 0
					BuyBulkDidJob.perform_later(@funnel.id, @funnel.name, funnel_params['bulk_dids'].to_i, area_codes)
				end
        format.js { flash[:notice] = 'The camapign has been added.' }
      else
        @error = true
        format.js { flash[:error] = @funnel.errors }
      end
    end
  end
  
  def edit
    @funnel = Funnel.find(params[:id])
  end
  
  def update
    @funnel = Funnel.find(params[:id])
    @funnel.update_attributes(funnel_params)
  end
  
  def buy_dids
    @funnel = Funnel.find_by_id(params[:funnel][:id])
    
    respond_to do |format|
      if @funnel.blank?
        @error = false
        format.js { flash[:error] = 'Please select a funnel for your bulk DID purchase.' }
      elsif params[:funnel][:bulk_dids].to_i == 0
        @error = true
        format.js { flash[:error] = 'The number of dids to purchase has to be greater than zero.' }
      else
        @funnel.bulk_dids = params[:funnel][:bulk_dids].to_i
        @funnel.toll_free = params[:funnel][:toll_free].to_i
        @funnel.selected_states = params[:funnel][:selected_states]
        if @funnel.has_enough_balance
					area_codes = ApplicationController.new.get_state_area_codes(@funnel.selected_states)
					area_codes = ['TFNS'] if @funnel.toll_free > 0
          BuyBulkDidJob.perform_later(@funnel.id, @funnel.name, funnel_params['bulk_dids'].to_i, area_codes)
          format.js { flash[:notice] = 'Your bulk DID purchase is being processed and you will receive an email report in a few minutes.' }
        else
          @error = true
          format.js { flash[:error] = 'Your account does not have enough funds for this DID purchase.' }
        end
      end
    end
  end
  
  def destroy
    funnel = Funnel.find(params[:id])
    funnel.destroy
  end
  
  private
  
  def funnel_params
    params.require(:funnel).permit(:name, :forwarding_number, :vertical_id, :routing_type, :mask_number, :did_ids, :bulk_dids, :toll_free, selected_states: [], campaign_ids: [])
  end
end
