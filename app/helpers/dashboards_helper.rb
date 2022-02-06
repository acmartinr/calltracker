module DashboardsHelper
  def active(path)
    if current_page?(path)
      return 'btn btn-default active'
    else
      return 'btn btn-default'
    end
  end
  
  def quickview_active(page)
    if @active == page
      return 'btn btn-primary-outlined btn-sm active'
    else
      return 'btn btn-primary-outlined btn-sm'
    end
  end
  
  def fetch_live_calls
    live_calls = Rails.cache.fetch('live_calls', expires_in: 5.seconds) { Vicidial.default_api.all_agents_status }
		#live_calls = Vicidial.default_api.all_agents_status
    campaigns = current_user.campaigns    
    calls_to_display = Array.new
		
    live_calls.each do |live_call|
			live_call.map! { |e| e ? e : '0' }
			
			if Rails.env.development?
				calls_to_display << live_call
			else
				# Check if the live_call agent ID matches the range of possible agent IDs for a given camapign:
      	campaign = campaigns.find_all { |c| live_call[0].to_i.between?( c.vicidial_agent_user.to_i, (c.vicidial_agent_user.to_i + c.concurrent_call_limit.to_i - 1) ) }.first
			end
      unless campaign.blank?
        live_call[0] = campaign.client_did
				live_call.push(campaign.name)
        calls_to_display << live_call
      end
    end
		
		calls_to_display.sort_by! { |x| x[3].to_i } unless calls_to_display.blank?
		
		Rails.logger.debug "calls to display: #{calls_to_display}"
		
    calls_to_display
  end
	
	def setup_status
		html = "<p>".html_safe
		if current_user.campaigns.blank?
			link = link_to('new destination', campaigns_path, remote: true, style: 'color:#1da3ed;')
			html.safe_concat("Your first step in setting up your account is to create a #{link}. ")
		end
		if current_user.funnels.blank?
			link = link_to('new funnel', funnels_path, remote: true, style: 'color:#1da3ed;')
			html.safe_concat("You'll need to set up a #{link} for calls to flow through. ")
		end
		html.safe_concat("</p>")
		html
	end
end
