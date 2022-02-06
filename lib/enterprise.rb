require 'faraday'

class Enterprise
  def initialize(root_url:, token:)
    @root_url, @token = root_url, token
  end

  def self.default_api	
    @default_api ||= new(
      root_url: 'https://api.telnyx.com/v2',
      token: Rails.application.credentials.enterprise_token
    )
  end
	
	def get_call_flows
    response = Faraday.get(
      "https://apiv1.teleapi.net/flows/list", {
        token: @token
      }
    )
	end
	
	def list_ip_endpoints
    response = Faraday.get(
      'https://apiv1.teleapi.net/ipendpoints/list', {
        token: @token
      }
    )
	end
	
	def get_vici_call_flow
		endpoints = JSON.parse(list_ip_endpoints.body)
		vici_endpoint = endpoints['data'].select { |x| x['ip_address'] == '66.165.241.18' }.first
		return vici_endpoint['id']
	end
	
	def list_npas
    response = Faraday.get(
      'https://apiv1.teleapi.net/dids/npas', {
        token: @token
      }
    )
	end
	
	def list_local_numbers(area_code)
    response = Faraday.get(
      'https://apiv1.teleapi.net/dids/list', {
        token: @token,
				npa: area_code
      }
    )
	end
	
	def list_tollfree_numbers
    response = Faraday.get(
      'https://apiv1.teleapi.net/dids/list', {
        token: @token,
				type: 'tollfree'
      }
    )
	end
	
	def transact_did_purchase(number, call_flow)
    response = Faraday.get(
      'https://apiv1.teleapi.net/dids/order', {
        token: @token,
				number: number,
				call_flow: call_flow.to_i
      }
    )
	end
	
	def buy_bulk_tollfree_dids(number_of_dids)
		vici_id = get_vici_call_flow
		tfns_bought = Array.new
		
		number_of_dids.to_i.times do
			available_tfns = JSON.parse( Enterprise.default_api.list_tollfree_numbers.body )
			random_tfn = available_tfns['data']['dids'].to_a.sample['number']
			redo if tfns_bought.include?(random_tfn)
			
			response = transact_did_purchase(random_tfn, vici_id)
			response_json = JSON.parse(response.body)
			if response_json['status'].downcase == 'success'
				tfns_bought.push(response_json['data']['number'])
				Rails.logger.debug(tfns_bought)
			else
				redo
			end
		end
		return tfns_bought
	end
	
	#area_codes is an array:
	def buy_bulk_random_dids(number_of_dids, area_codes)
		Rails.logger.info("Area codes requested: #{area_codes}")
		vici_id = get_vici_call_flow
		napas = JSON.parse(list_npas.body)
		Rails.logger.info("Napas: #{napas}")
		random_area = ''
		dids_bought = Array.new
		
		if napas['status'] = 'success'
			number_of_dids.to_i.times do
				while random_area.size != 3 do
					random_area = napas['data'].to_a.sample.last
					Rails.logger.info("Attempting match: #{random_area}")
					
					unless area_codes.blank?
						random_area = '' unless area_codes.include?(random_area.to_i)
					end
				end
				
				Rails.logger.info("random_area value: #{random_area}")
				
				available_dids = JSON.parse( list_local_numbers(random_area).body )
				random_area = ''
        Rails.logger.info("available_dids: #{available_dids}")
        next if available_dids['data']['dids'].blank?
        
				random_did = available_dids['data']['dids'].to_a.sample['number']
				redo if dids_bought.include?(random_did)
				
		    response = transact_did_purchase(random_did, vici_id)
				response_json = JSON.parse(response.body)
        Rails.logger.info("Purchase attempt response: #{response_json}")
				if response_json['status'].downcase == 'success'
					dids_bought.push(response_json['data']['number'])
					Rails.logger.info("dids_bought value: #{dids_bought}")
				else
          Rails.logger.info("Purchase attempt failed. Retrying.")
					redo
				end
				
			end
      Rails.logger.info("dids_bought final value: #{dids_bought}")
			return dids_bought
		end
		return false
	end
	
	def buy_random_did
		vici_id = get_vici_call_flow
		dids = JSON.parse(list_npas.body)
		random_area = ''
		if dids['data'].to_a.size > 100
			while random_area.size != 3 do
				random_area = dids['data'].to_a.sample.last
			end
		end
		available_dids = JSON.parse( list_local_numbers(random_area).body )
		random_did = available_dids['data']['dids'].to_a.sample['number']
		
		#Order the DID
    response = transact_did_purchase(random_did, vici_id)
		
		return JSON.parse(response.body)
	end
end
