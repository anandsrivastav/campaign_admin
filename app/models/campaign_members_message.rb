class CampaignMembersMessage < ApplicationRecord
  belongs_to :campaign_member
  belongs_to :campaign_message
end
