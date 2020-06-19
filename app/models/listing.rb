class Listing < ApplicationRecord
  belongs_to :user
  validates_presence_of :name

  has_many :members_listings, dependent: :destroy
  has_many :listing_members, through: :members_listings, dependent: :destroy


  def get_members_count
    self.listing_members.count
  end

end
