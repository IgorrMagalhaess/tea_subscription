class Subscription < ApplicationRecord
  belongs_to :customer

  enum :status, [:active, :cancelled]
  enum :frequency, [:weekly, :monthly]

  validates :title, presence: true
  validates :price, presence: true
  validates :frequency, presence: true
end
