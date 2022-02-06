class Campaign < ApplicationRecord
  belongs_to :vertical
  has_and_belongs_to_many :funnels, optional: true
  has_many :contacts
  serialize :blocked_states
  validates_presence_of :vertical_id, :name, :client_did
  after_commit :setup_agent, on: [:create]
  after_commit :update_remote_agent, on: [:update]
  after_commit :check_funnel
  before_destroy :delete_agent, prepend: true
  
  enum campaign_type: [:default, :buyer, :vendor]
  
  def setup_agent
    Vicidial.default_api.add_agent_user(self)
  end
  
  def delete_agent
    Vicidial.default_api.delete_agent_user(self)
  end
  
  def update_remote_agent
    Vicidial.default_api.update_remote_agent(self)
  end
  
  # Check the funnels DIDs and area code blocking
  def check_funnel
    self.funnels.each do |funnel|
      Vicidial.default_api.update_filter_phone_group(funnel)
      
      funnel.dids.each do |did|
        Vicidial.default_api.update_did(did)
      end
      
    end
  end
	
	def to_csv(campaign)
		contact_names = %w( phone_number term_reason length_in_sec )
	  CSV.generate do |csv|
	    csv << ['Destination'].concat( contact_names.map { |c| c.titleize }, ).concat(['Date'])
			
	    campaign.contacts.each do |contact|
	      csv << [contact.campaign.name.strip].concat( contact.attributes.values_at(*contact_names) ).concat( [contact.created_at.to_formatted_s(:short)] )
	    end			
	  end
	end
	
end
