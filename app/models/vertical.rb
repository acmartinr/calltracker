class Vertical < ApplicationRecord
  belongs_to :user
  has_many :campaigns

  validates_uniqueness_of :name, scope: [:user_id]
end
