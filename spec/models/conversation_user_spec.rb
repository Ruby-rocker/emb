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

require 'spec_helper'

describe ConversationUser do
  pending "add some examples to (or delete) #{__FILE__}"
end
