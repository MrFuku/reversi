class Room < ApplicationRecord
  has_one :game
  belongs_to :owner, class_name: 'User', :foreign_key => 'owner_id'
  belongs_to :guest, class_name: 'User', :foreign_key => 'guest_id'
end
