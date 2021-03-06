class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  has_one :own_room, class_name: 'Room', :foreign_key => 'owner_id', dependent: :destroy
  has_one :guest_room, class_name: 'Room', :foreign_key => 'guest_id', dependent: :destroy
  has_many :sent_requests, class_name: "FriendRequest", foreign_key: "from_user_id", dependent: :destroy
  has_many :received_requests, class_name: "FriendRequest", foreign_key: "to_user_id", dependent: :destroy
  has_many :sent_users, through: :sent_requests, source: :to_user
  has_many :received_users, through: :received_requests, source: :from_user
  has_many :friendships, class_name: "Friendship", foreign_key: "user_id", dependent: :destroy
  has_many :friends, through: :friendships, source: :friend
  has_one :result, dependent: :destroy
  validates :name, presence: true, length: { maximum: 20 }
  validate :only_one_room

  def get_room
    if room = own_room || guest_room
      room.id
    end
  end

  def sent_request(user)
    sent_users << user
  end

  def cancel_request(user)
    sent_requests.find_by(to_user_id: user.id).destroy
  end

  def sent_request?(user)
    sent_users.include?(user)
  end

  def received_request?(user)
    received_users.include?(user)
  end

  def add_friend(user)
    Friendship.transaction do
      self.friends << user
      user.friends << self
    end
  end

  def friend?(user)
    friends.include?(user)
  end

  def remove_friend(user)
    Friendship.transaction do
      self.friends.delete(user)
      user.friends.delete(self)
    end
  end

  def number_of_wins
    self.result.wins
  end

  def number_of_losses
    self.result.losses
  end

  def number_of_draws
    self.result.draws
  end

  def number_of_games
    self.number_of_wins + self.number_of_losses + self.number_of_draws
  end

  def add_wins
    self.result.wins += 1
    self.result.save!
  end

  def add_losses
    self.result.losses += 1
    self.result.save!
  end

  def add_draws
    self.result.draws += 1
    self.result.save!
  end

  private

  def only_one_room
    if own_room && guest_room
      errors.add(:room, "Too many associations")
    end
  end
end
