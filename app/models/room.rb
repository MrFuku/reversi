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
    return stone
  end

  def belongs_to?(user)
    self.owner == user || self.guest == user
  end

  def has_password?
    self.password_digest != nil
  end

  def track_record(token)
    User.transaction do
      if token == "draw"
        self.owner.add_draws
        self.guest.add_draws
      elsif token == "win_black"
        self.owner.add_wins
        self.guest.add_losses
      elsif token == "win_white"
        self.owner.add_losses
        self.guest.add_wins
      else
        raise
      end
    end
  end

  def dropout_user(user)
    if belongs_to?(user) && self.owner && self.guest && self.game&.end? == false
      token = self.color?(user) == "b" ? "win_white" : "win_black"
      self.game.set_message(token)
      self.track_record(token)
    end
  end

  private

  def exist_guest
    if self.guest_id && User.find_by(id: self.guest_id) == nil
      errors.add(:guest, "は存在しないユーザーです")
    end
  end
end
