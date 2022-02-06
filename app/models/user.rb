class User < ApplicationRecord
  has_secure_password
  has_secure_token :confirm_token
  has_secure_token :password_reset_token
  attr_accessor :remember_token
	# Verify that email field is not blank and that it doesn't already exist in the db (prevents duplicates):
	validates :email, presence: true, uniqueness: true
  has_many :sources
  has_many :funnels
  has_many :dids, through: :funnels
  has_many :verticals
  has_many :charges
  has_many :campaigns, through: :verticals
  has_many :agents, through: :campaigns
	has_many :ivrs
  after_commit :set_defaults, on: [:create]
  
  # Returns the hash digest of the given string:
  def User.digest(string)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                  BCrypt::Engine.cost
    BCrypt::Password.create(string, cost: cost)
  end
  
  def User.new_token
    SecureRandom.urlsafe_base64
  end
  
  # Remembers a user in the database for use in persistent sessions:
  def remember
    self.remember_token = User.new_token
    update_attribute(:remember_digest, User.digest(remember_token))
  end
  
  # Forgets a user.
  def forget
    update_attribute(:remember_digest, nil)
  end
  
  def authenticated?(remember_token)
    return false if remember_digest.nil?
    BCrypt::Password.new(remember_digest).is_password?(remember_token)
  end
  
  def send_email_confirmation
    UserMailer.email_confirmation(self).deliver
  end
  
  def send_buyer_email_confirmation
    UserMailer.email_buyer_confirmation(self).deliver
  end
  
  def send_password_reset
    self.password_reset_sent_at = Time.zone.now
    save!
    UserMailer.password_reset(self).deliver
  end
  
  def enough_cash?(purchase_amount)
    if self.balance >= purchase_amount
      return true
    else
      return false
    end
  end
  
  # Here's where we populate some useful defaults for new users:
  def set_defaults
    vertical_names = [
      'Auto Finance',
      'Auto Insurance (Basic)',
      'Auto Insurance (Advanced)',
      'Auto Warranty',
      'Byetta',
      'Debt Consolidation',
      'Diabetic',
      'Education',
      'Granuflo',
      'Health Insurance',
      'Hip Replacement',
      'Home Improvement',
      'Life Insurance',
      'Low Testosterone',
      'Mortgage',
      'Mortgage Refinance',
      'New Car Purchase',
      'Pain Cream',
      'Payday (US)',
      'Payday (UK)',
      'Satellite Television',
      'Social Security Disability (SSD)',
      'Tax Debt',
      'Transvaginal Mesh (TVM)',
      'Yaz/Yasmin/Ocella'
    ]
    vertical_names.each do |vertical_name|
      self.verticals.create(name: vertical_name)
    end
    
    source_names = [
      'Email',
      'Ringless Voicemail',
      'SMS',
      'Call Center',
      'Media ',
      'Facebook ',
      'PPC',
      'Direct Mail'
    ]
    source_names.each do |source_name|
      self.sources.create(name: source_name)
    end
    
    #Set billing rate to the global default:
    self.billing_rate = Global.find_by_name('default_billing_rate').value
  end
  
end
