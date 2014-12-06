# == Schema Information
#
# Table name: friendships
#
#  id          :integer          not null, primary key
#  sender_id   :integer          indexed => [receiver_id]
#  receiver_id :integer          indexed => [sender_id]
#  pending     :boolean          default(TRUE)
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class Friendship < ActiveRecord::Base

  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'

  attr_accessible :sender, :receiver

  validates_presence_of :sender_id, :receiver_id
  validates_uniqueness_of :receiver_id, scope: :sender_id
  validate :self_friending, on: :create
  validate :existing_friendship, on: :create

  scope :pending, where(pending: true)

  def self.for_user(user)
    where{ (sender_id == user.id) | (receiver_id == user.id) }
  end

  def self.between_users(user_1, user_2)
    where{
      (sender_id == user_1.id) & (receiver_id == user_2.id) |
      (sender_id == user_2.id) & (receiver_id == user_1.id)
    }
  end

  def approved?
    !self.pending
  end

  def pending?
    self.pending
  end

  protected

    def self_friending
      if sender_id == receiver_id
        return errors.add(:base, "it's not possible to friend yourself")
      end
    end

    def existing_friendship
      if sender && receiver && Friendship.between_users(sender, receiver).any?
        return errors.add(:base, "you are already friends")
      end
    end

end
