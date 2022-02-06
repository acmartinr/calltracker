# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

case Rails.env
  when 'development'
    Global.create(
      name: 'default_billing_rate',
      value: '0.01'
    )
    
    User.create(
      name: 'Burk Morrison',
      email: 'burk@mac.com',
      password: 'AzXTVhprYje5',
      password_confirmation: 'AzXTVhprYje5',
      email_confirmed: true,
      billing_rate: '0.01'
    )
    
    dids = [
			'4243894431',
			'4243894434',
			'4243894437',
			'4243894438',
			'4243894441'
    ]    
    dids.each do |did|
      Did.create(
        number: did
      )
    end
    
  when 'production'
    dids = [
			'4243894431',
			'4243894434',
			'4243894437',
			'4243894438',
			'4243894441'
    ]    
    dids.each do |did|
      Did.create(
        number: did
      )
    end
    
    Global.create(
      name: 'default_billing_rate',
      value: '0.01'
    )
    
    Global.create(
      name: 'default_local_did_price',
      value: '1.0'
    )
    
    Global.create(
      name: 'default_tfn_price',
      value: '1.5'
    )
end
