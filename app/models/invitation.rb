class Invitation < ApplicationRecord
  #belongs_to :receiver, class_name: "Lead", foreign_key:"receiver_id", dependent: :destroy
  #belongs_to :campaign
  belongs_to :user
  validates_presence_of :email
end
