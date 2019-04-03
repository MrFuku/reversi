class Room < ApplicationRecord
  has_one :game, dependent: :destroy
  has_many :chats, dependent: :destroy
  belongs_to :owner, class_name: 'User', :foreign_key => 'owner_id'
  belongs_to :guest, class_name: 'User', :foreign_key => 'guest_id', optional: true
  has_secure_password validations: false
  validates :password, presence: false, confirmation: true
  validate :exist_guest

  def color?(user)
    stone = "none"
    stone = "b" if user == owner
    stone = "w" if user == guest
    stone
  end

  def belongs_to?(user)
    self.owner == user || self.guest == user
  end

  def has_password?
    self.password_digest != nil
  end

  private

  def exist_guest
    if self.guest_id && User.find_by(id: self.guest_id) == nil
      errors.add(:guest, "は存在しないユーザーです")
    end
  end
end
