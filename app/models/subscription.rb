class Subscription < ApplicationRecord
  belongs_to :customer

  enum :status, [:active, :cancelled]
  enum :frequency, [:weekly, :monthly]
end
