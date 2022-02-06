class Did < ApplicationRecord
  belongs_to :funnel, optional: true
  after_commit :setup_vicidial, on: [:update]
  
  def setup_vicidial
    Vicidial.default_api.add_did(self)
    Vicidial.default_api.update_did(self)
		
		if Did.where(funnel_id: nil).size < 6
			result = Enterprise.default_api.buy_random_did
			Did.create( number: result['data']['number'] ) if result['data']['number'].size == 10
		end
  end
end
