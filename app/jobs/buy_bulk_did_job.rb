class BuyBulkDidJob < ApplicationJob
  queue_as :default
	
	# Example call: BuyBulkDidJob.perform_later(funnel.id, funnel.name, 2)
	
	def to_csv(did_list)
		CSV.generate do |csv|
       csv << ['Number'].concat(['Funnel'])
			 did_list.each do |did|
				 csv << [did].concat([@funnel_name])
			 end
    end
	end

  def perform(funnel_id, funnel_name, purchase_number, area_codes)
		@funnel_name = funnel_name
    funnel = Funnel.find_by_id(funnel_id)
    user = funnel.user
    did_list = Array.new
		result = ''
    billing_rate = ''
		
		if area_codes.first == 'TFNS'
      billing_rate = Global.find_by_name('default_tfn_price').value.to_d
			dids_bought = Enterprise.default_api.buy_bulk_tollfree_dids(purchase_number)
		else
      billing_rate = Global.find_by_name('default_local_did_price').value.to_d
			dids_bought = Enterprise.default_api.buy_bulk_random_dids(purchase_number, area_codes)
		end
		
		dids_bought.each do |did_bought|
      user.decrement(:balance, billing_rate)
			new_did = Did.create(number: did_bought)
			new_did.funnel_id = funnel_id
			new_did.save
		end    
    user.save
		
		UserMailer.email_did_purchase(funnel, to_csv(dids_bought)).deliver
  end
end
