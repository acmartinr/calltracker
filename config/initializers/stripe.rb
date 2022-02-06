if Rails.env.development?
  Rails.configuration.stripe = {
    :publishable_key => 'pk_test_TYooMQauvdEDq54NiTphI7jx',
    :secret_key      => 'sk_test_4eC39HqLyjWDarjtT1zdp7dc'
  }
else
  Rails.configuration.stripe = {
    :publishable_key => Rails.application.credentials.stripe_publishable_key,
    :secret_key      => Rails.application.credentials.stripe_secret_key
  }
end

Stripe.api_key = Rails.configuration.stripe[:secret_key]
