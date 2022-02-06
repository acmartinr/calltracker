class Ivr < ApplicationRecord
	has_many :funnel_ivrs
	has_many :funnels, through: :funnel_ivrs
end
