class Chat < ApplicationRecord
  belongs_to :room
  validates :content, presence: true
end
