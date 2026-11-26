class Outfit < ApplicationRecord
  belongs_to :user
  has_one :chat, dependent: :destroy
  has_one_attached :photo
end
