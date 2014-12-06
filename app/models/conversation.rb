# == Schema Information
#
# Table name: conversations
#
#  id          :integer          not null, primary key
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  users_count :integer          default(0), not null, indexed
#

class Conversation < ActiveRecord::Base

  acts_as_readable on: :updated_at

  has_many :messages, dependent: :destroy
  has_many :conversation_users, dependent: :destroy
  has_many :users, through: :conversation_users

  after_create :update_user_count

  def self.for_users(users)
    user_ids = users.map(&:id)
    conversation_id = self.joins(:conversation_users)
      .where('conversations.users_count = ?', user_ids.size)
      .where{conversation_users.user_id.in my{user_ids}}
      .group('conversations.id')
      .having('COUNT(*) = ?', user_ids.size)
      .pluck(:id).first

    # load it separately to avoid ReadOnlyRecord errors
    Conversation.find_by_id conversation_id
  end

  private

    def update_user_count
      update_attribute :users_count, users.pluck(:id).uniq.size
    end

end
