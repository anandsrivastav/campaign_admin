class PaymentNotification < ApplicationRecord
  belongs_to :user
  validates_presence_of :payer_id, :payment_id, :payment_token
end
