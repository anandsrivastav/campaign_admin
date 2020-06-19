class MembersListing < ApplicationRecord
  belongs_to :listing_member
  belongs_to :listing
end
