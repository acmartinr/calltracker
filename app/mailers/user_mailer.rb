class UserMailer < ApplicationMailer
	def sanitize_filename(filename)
	  filename.gsub(/[^0-9A-z.\-]/, '_')
	end
	
  def password_reset(user)
    @user = user
    @url = 'http://example.com/login'
    @subject = 'VD CallRouter Password Reset Link'
    mail(to: @user.email, subject: @subject)
  end

  def email_confirmation(user)
    @user = user
    @url = 'http://example.com/login'
    @subject = 'Confirm Your Email With VD CallRouter'
    mail(to: @user.email, subject: @subject)
  end
  
  def email_buyer_confirmation(user)
    @user = user
    @url = 'http://example.com/login'
    @subject = 'Confirm Your Buyer Email With VD CallRouter'
    mail(to: @user.email, subject: @subject)
  end
	
  def billing_alert(user)
    @user = user
		@amount = Global.where(name: 'billing_reminder').first
    @url = 'https://app.veritechcallrouting.com/login'
    @subject = 'Fund Your VD CallRouter Account'
    mail(to: @user.email, subject: @subject)
  end
	
	def email_did_purchase(funnel, csv)
		@user = funnel.user
		@subject = 'Your Bulk DID Purchase Is Complete'
		attachments["#{funnel.name.parameterize}-dids.csv"] = { mime_type: 'text/csv', content: csv }
		mail(to: @user.email, subject: @subject, body: 'Your bulk DID purchase is complete. Please check the attached CSV file for detailed information.')
	end
end
