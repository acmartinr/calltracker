# Define a namespace for the task
namespace :vicidial do
  # Give a description for the task
  desc "Check for funnel-less DIDs"
  # Define the task
  task check_no_funnel_dids: :environment do 
    
    # Your task goes here
		dids_to_check = Did.where(funnel_id: nil)
		
		dids_to_check.each do |did|
			Vicidial.default_api.update_did(did)
		end    
  end
	
  desc "Update all DIDs"
  # Define the task
  task update_all_dids: :environment do 
    
    # Your task goes here
		dids_to_update = Did.all
		
		dids_to_update.each do |did|
			Vicidial.default_api.update_did(did)
		end    
  end
end