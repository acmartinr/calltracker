class Charge < ApplicationRecord
  belongs_to :user
  belongs_to :contact, optional: true
  scope :recent, -> { order('id DESC').limit(100) }
  
  def self.bill_contact(user, contact)
    user.update_attribute(:billing_rate, Global.find_by_name('default_billing_rate').value) if user.billing_rate.blank?
    contact.charges.create(
      user_id: user.id,
      amount: -(user.billing_rate)
    )
    user.decrement!(:balance, by = user.billing_rate)
		
		billing_alert = Rails.cache.fetch('billing_alert', expires_in: 15.minutes) { Global.where(name: 'billing_reminder').first.value }
		if user.balance.to_f < billing_alert.to_f && user.send_billing_reminder?
			user.update_attribute(:send_billing_reminder, false) if UserMailer.billing_alert(user).deliver
		end
  end
end
