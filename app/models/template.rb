class Template < ApplicationRecord
  belongs_to :user
  has_many :campaign_messages
end
