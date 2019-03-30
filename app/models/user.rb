class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :own_room, class_name: 'Room', :foreign_key => 'owner_id', dependent: :destroy
  has_one :guest_room, class_name: 'Room', :foreign_key => 'guest_id', dependent: :destroy
  validate :only_one_room

  def get_room
    if room = own_room || guest_room
      room.id
    end
  end

  def only_one_room
    if own_room && guest_room
      errors.add(:room, "Too many associations")
    end
  end
end
