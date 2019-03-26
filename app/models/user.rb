class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :own_room, class_name: 'Room', :foreign_key => 'owner_id'
  has_one :guest_room, class_name: 'Room', :foreign_key => 'guest_id'

  def get_room
    if room = own_room || guest_room
      room.id
    end
  end
end
