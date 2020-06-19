class CampaignMessage < ApplicationRecord
  belongs_to :campaign
  belongs_to :template, optional: true

  #before_create :update_sending_date
  validates_presence_of :description

  has_many :campaign_members_messages
  has_many :campaign_members, through: :campaign_members_messages

  # private

  # def update_sending_date
  #   self.sending_date = self.created_at.to_date + self.number_of_days
  # end

end
