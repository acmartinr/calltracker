class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session
  include SessionsHelper

  def authorize
    redirect_to login_url unless helpers.logged_in?
  end
   
  def disable_navbar
    @disable_navbar = true
  end
  
  def redirect_to_welcome
    redirect_to welcome_url
  end
	
	def get_state_area_codes(states)
		area_codes = JSON.parse( File.open(File.join(Rails.root, '/lib', 'us_area_codes.json')).read )
		usa_states = CampaignsController.helpers.states
		full_state_names = Array.new
		usa_states.each { |x| full_state_names.push x.last if states.include?(x.first) }
		matching_acs = Array.new
		area_codes.each { |y| matching_acs.push y.last if full_state_names.include?(y.first) }
		return matching_acs.flatten
	end
end
