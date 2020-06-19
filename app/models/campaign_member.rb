class CampaignMember < ApplicationRecord
  belongs_to :campaign
  validates_presence_of :public_identifier
  after_create :create_log, :create_mapping

  has_many :campaign_members_messages
  has_many :campaign_messages, through: :campaign_members_messages

  private

    def create_log
      case self.campaign.campaign_type 
        when 'connect'
          log_message = "<span> Sent invitation to <a target='_blank' href=#{self.profile_url}>#{self.full_name}</a></span>"
        when 'message'
          log_message = "<span> Message sent to <a target='_blank' href=#{self.profile_url}>#{self.full_name}</a></span>"
        when 'visit'
          log_message = "<span> Visited profile of <a target='_blank' href=#{self.profile_url}>#{self.full_name}</a></span>"
      end
      self.campaign.campaign_logs.create(log:log_message)
    end


    def create_mapping
      self.campaign.campaign_messages.each do |campaign_message|
        CampaignMembersMessage.create(campaign_member_id:self.id,campaign_message_id:campaign_message.id)
      end if self.campaign.campaign_type == 'connect'
    end

end




