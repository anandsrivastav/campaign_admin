class Tag < ApplicationRecord
  belongs_to :campaign
  belongs_to :user, optional:true
  validates_presence_of :name
  validates_uniqueness_of :name
end
