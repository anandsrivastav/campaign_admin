class BlacklistMember < ApplicationRecord
  
  validates_presence_of :profile_url

  belongs_to :user
end
