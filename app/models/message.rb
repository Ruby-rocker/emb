# == Schema Information
#
# Table name: messages
#
#  id              :integer          not null, primary key
#  conversation_id :integer          indexed
#  user_id         :integer          indexed
#  body            :text
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class Message < ActiveRecord::Base

  acts_as_readable on: :created_at

  belongs_to :conversation
  belongs_to :user

  attr_accessible :body

  after_create :mark_as_read_for_user
  after_create :update_conversation

  validates :user, presence: true
  validates :body, presence: true

  searchable do
    integer :id
    integer :user_id
    text :body
  end

  def mark_as_read_for_user
    mark_as_read! for: user
  end

  def update_conversation
    conversation.touch
    conversation.mark_as_read! for: user
  end
end
