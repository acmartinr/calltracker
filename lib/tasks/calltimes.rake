# Define a namespace for the task
namespace :calltimes do
  # Give a description for the task
  desc "Process destination/campaign call times"
  # Define the task
  task check: :environment do 
    
    # Your task goes here    
    campaigns_to_check = Campaign.where.not(schedule_start: [nil, ''], schedule_end: [nil, ''])
    campaigns_to_check.each do |campaign|
      time_start = Time.parse( campaign.schedule_start.strftime("%H:%M:%S %Z") )
      time_end = Time.parse( campaign.schedule_end.strftime("%H:%M:%S %Z") )
      
      should_be_active = (time_start..time_end).cover? Time.current
      
      if campaign.vicidial_remote_agent?       
        campaign.update_attribute(:active, should_be_active) if should_be_active != campaign.active
      end      
    end
    
  end
end