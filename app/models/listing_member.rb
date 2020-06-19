class ListingMember < ApplicationRecord
  
  validates_presence_of   :full_name, :profile_url

  has_many :members_listings
  has_many :listing, through: :members_listings

end
