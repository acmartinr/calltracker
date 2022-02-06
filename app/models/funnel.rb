class Funnel < ApplicationRecord
  belongs_to :user
  belongs_to :vertical, optional: true
  has_and_belongs_to_many :campaigns, optional: true, after_remove: :check_remote_agents
  has_many :dids, autosave: true
	has_many :funnel_ivrs
	has_many :ivrs, through: :funnel_ivrs
  accepts_nested_attributes_for :campaigns
  accepts_nested_attributes_for :dids
  validates_presence_of :name, message: 'Name cannot be blank.'
  validates_presence_of :routing_type, message: 'You must select a routing type.'
  validates_presence_of :vertical_id, message: 'You must select a vertical.'
  validates_presence_of :did_ids, message: 'You must pick an available inbound DID.', if: :bulk_did_purchase?
  validates_presence_of :campaign_ids, message: 'You must select a destination.'
  validate :has_enough_balance
  after_commit :setup_vicidial, on: [:create, :update]
  before_destroy :remove_vicidial_ingroup, prepend: true
  after_destroy :check_remote_agents
	
	attr_accessor :bulk_dids
	attr_accessor :toll_free
	attr_accessor :selected_states
  
  enum routing_type: [:round_robin, :priority]
	
  def has_enough_balance
    if bulk_did_purchase?
      number_of_dids = self.bulk_dids.to_i
    else
      number_of_dids = 1
    end
    
    subtotal = 0.0
    if self.toll_free.to_i > 0
      subtotal = Global.where(name: 'default_tfn_price').first.value.to_d * number_of_dids
    else
      subtotal = Global.where(name: 'default_local_did_price').first.value.to_d * number_of_dids
    end
    
    if self.user.enough_cash?(subtotal)
      return true
    else
      errors.add(:check_your_balance, 'Your account does not have enough funds for your DID purchase.')
      return false
    end  
  end
  
	def bulk_did_purchase?
		self.bulk_dids.to_i == 0
	end
  
  def setup_vicidial
    # 1: Ensure Vicidial ingroups are set:
    if self.vicidial_ingroup_id.blank?
      Vicidial.default_api.add_ingroup(self)
    end
    
    # 2: Ensure each remote agent is set:
    self.campaigns.each do |campaign|
      if campaign.vicidial_remote_agent?
        Vicidial.default_api.update_remote_agent(campaign)
      else
        Vicidial.default_api.add_remote_agent(campaign)
      end
    end
    
    # 3: Set up inbound area code blocking if defined by camapign/destination:
    Vicidial.default_api.update_filter_phone_group(self) unless self.dids.first.blank?
  end
  
  def remove_vicidial_ingroup
    Vicidial.default_api.delete_ingroup(self) unless self.vicidial_ingroup_id.blank?
    
    self.dids.each do |did|
      Vicidial.default_api.update_did(did)
    end
  end
  
  def check_remote_agents
    self.user.campaigns.each do |campaign|
      Vicidial.default_api.update_remote_agent(campaign) if campaign.funnels.blank?
    end
  end
end
