namespace :db do
  desc "Generate fake data, like calls, for development"
  task genfakedata: :environment do
    50.times do
      # random info
      user = User.all.sample
      did = user.dids.all.sample
      funnel = did.funnel
      campaign = funnel.campaigns.all.sample
      
      # Let's pretend a new lead has been sent/call started.
      info = {
        lead_id: rand.to_s[2..6].to_i,
        vendor_id: did.number,
        phone_number: rand.to_s[2..11]
      }
      contact = campaign.contacts.create(info)
      Did.increment_counter(:calls_count, did.id)
      Vertical.increment_counter(:calls_count, did.funnel.vertical.id)
      
      # Let's pretend a call has just ended.
      call_length = rand(300)
      contact.update_attribute(:length_in_sec, call_length)

      if call_length > campaign.buffer.to_i
        Campaign.increment_counter(:sold_count, campaign.id)
        Did.increment_counter(:sold_count, did.id)
        Vertical.increment_counter(:sold_count, did.funnel.vertical.id)
      end
      
      Charge.bill_contact(user, contact)
      talk_total = campaign.contacts.sum(:length_in_sec)
      campaign.update_attribute(:talk_average, talk_total / campaign.contacts.size)
    end
  end
	
	desc "Purchase a random DID and add it to the database if fewer than 8 available"
	task buyrandomdid: :environment do
		while Did.where(funnel_id: nil).size < 8
			result = Enterprise.default_api.buy_random_did
			if result['status'] == 'success'
				puts "Purchased #{result['data']['number']}." if Did.create( number: result['data']['number'] )
			end
		end
	end

end
