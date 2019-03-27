class Room < ApplicationRecord
  has_one :game, dependent: :destroy
  belongs_to :owner, class_name: 'User', :foreign_key => 'owner_id'
  belongs_to :guest, class_name: 'User', :foreign_key => 'guest_id', optional: true
  has_secure_password validations: false
  validates :password, presence: false, confirmation: true

  def is_turn?(user)
    now_user = self.turn_user == 0 ? owner : guest
    now_user == user
  end

  def color?
    self.turn_user == 0 ? "b" : "w"
  end

  def change_turn
    self.turn_user ^= 1
    save
  end

  def get_message
    message = self.turn_user == 0 ? "黒" : "白"
    message += "のターンです。"
  end

  def belongs_to?(user)
    self.owner == user || self.guest == user
  end

  def has_password?
    self.password_digest != nil
  end
end
