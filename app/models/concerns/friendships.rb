module Friendships
  extend ActiveSupport::Concern

  included do
    has_many :sent_friendships,
      class_name: 'Friendship',
      foreign_key: 'sender_id',
      dependent: :destroy

    has_many :pending_sent_friendships,
      through: :sent_friendships,
      source: :receiver,
      conditions: { :'friendships.pending' => true }

    has_many :accepted_sent_friendships,
      through: :sent_friendships,
      source: :receiver,
      conditions: { :'friendships.pending' => false }

    has_many :received_friendships,
      class_name: 'Friendship',
      foreign_key: 'receiver_id',
      dependent: :destroy

    has_many :pending_received_friendships,
      through: :received_friendships,
      source: :sender,
      conditions: { :'friendships.pending' => true }

    has_many :accepted_received_friendships,
      through: :received_friendships,
      source: :sender,
      conditions: { :'friendships.pending' => false }
  end

  def send_friendship_request_to(user)
    Friendship.create(sender: self, receiver: user)
  end

  def approve_friendship_with(user)
    friendship = find_any_friendship_with(user)
    return false if friendship.nil? || sent_friendship_to?(user)
    friendship.update_attribute(:pending, false)
  end

  def remove_friendship_with(user)
    friendship = find_any_friendship_with(user)
    return false if friendship.nil?
    friendship.destroy && friendship.destroyed?
  end

  def friend_ids(options = {})
    received_ids = Friendship.where do
      conditions = {}
      options = my{options}
      conditions[receiver_id] = my{id}
      conditions[pending] = false unless options[:include_pending]
      conditions[pending] = true if options[:pending]
      conditions
    end.pluck(:sender_id)

    sent_ids = Friendship.where do
      conditions = {}
      options = my{options}
      conditions[sender_id] = my{id}
      conditions[pending] = false unless options[:include_pending]
      conditions[pending] = true if options[:pending]
      conditions
    end.pluck(:receiver_id)

    sent_ids + received_ids
  end

  def find_friends(options = {})
    User.where(id: friend_ids(options))
  end

  def friends
    find_friends
  end

  def pending_friends
    find_friends(pending: true)
  end

  def total_friends_count
    count = 0
    count += accepted_sent_friendships(false).count
    count += accepted_received_friendships(false).count
  end

  # only approved friends
  def friends_with?(user)
    friends.include?(user)
  end

  # both approved and pending friends
  def connected_with?(user)
    find_any_friendship_with(user).present?
  end

  def received_friendship_from?(user)
    friendship = find_any_friendship_with(user)
    return false if friendship.nil?
    friendship.sender == user
  end

  def sent_friendship_to?(user)
    friendship = find_any_friendship_with(user)
    return false if friendship.nil?
    friendship.receiver == user
  end

  def common_friends_with(user)
    friends & user.friends
  end

  def find_any_friendship_with(user)
    Friendship.between_users(self, user).first
  end
end
