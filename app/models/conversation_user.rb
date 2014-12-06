# == Schema Information
#
# Table name: conversation_users
#
#  id              :integer          not null, primary key
#  conversation_id :integer          indexed
#  user_id         :integer          indexed
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#

class ConversationUser < ActiveRecord::Base
  belongs_to :conversation
  belongs_to :user
end
