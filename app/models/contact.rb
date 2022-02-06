class Contact < ApplicationRecord
  belongs_to :campaign, counter_cache: true
  has_many :charges
end
