class ContactsController < ApplicationController
  skip_before_action :verify_authenticity_token
  
  def index
    if params[:key] = Rails.application.credentials.api_challenge
      # The old, dumb way of looking for a campaign is below:
      # campaign = Campaign.find_by(vicidial_agent_user: params[:user])
			# The new, better way: Check if the live_call agent ID matches the range of possible agent IDs for a given camapign:
    	campaign = Campaign.all { |c| params[:user].to_i.between?( c.vicidial_agent_user.to_i, (c.vicidial_agent_user.to_i + c.concurrent_call_limit.to_i - 1) ) }.first
      if campaign.blank?
        render json: { error: 'campaign/destination not found.' } and return
      end
      campaign.contacts.create(contacts_params)
      did = Did.find_by(number: params[:vendor_id])
      Did.increment_counter(:calls_count, did.id)
      Vertical.increment_counter(:calls_count, did.funnel.vertical.id)
    end
    render html: params
  end
  
  def update
    if params[:key] = Rails.application.credentials.api_challenge
      contact = Contact.find_by(lead_id: params[:lead_id])
      if contact.blank?
        Rails.logger.info("No contct found by lead_id #{params[:lead_id]}. Exiting.")
        render json: { error: 'lead_id not found.' } and return
      end
      campaign = contact.campaign
      Rails.logger.info("Campaign found: #{campaign}.")
      did = Did.find_by(number: contact.vendor_id)
      user = campaign.vertical.user
      Rails.logger.info("User found: #{user}.")
      
      contact.update_attributes(contacts_params)

      if params[:length_in_sec].to_i > campaign.buffer.to_i
        Campaign.increment_counter(:sold_count, campaign.id)
        Did.increment_counter(:sold_count, did.id)
        Vertical.increment_counter(:sold_count, did.funnel.vertical.id)
      end
      
      # Handle calculated fields and billing:
      Charge.bill_contact(user, contact)
      talk_total = campaign.contacts.sum(:length_in_sec)
      campaign.update_attribute(:talk_average, talk_total / campaign.contacts.size)
    end
    render json: params
  end
  
  def contacts_params
    params.permit(:lead_id, :vendor_id, :phone_number, :group, :user, :length_in_sec, :term_reason)
  end
end
