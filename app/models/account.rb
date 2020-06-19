class Account < ApplicationRecord
	has_many :users, dependent: :destroy
	has_many :campaigns, dependent: :destroy
end
