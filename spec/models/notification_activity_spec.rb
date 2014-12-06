# == Schema Information
#
# Table name: notification_activities
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  activity_id :integer
#  read        :boolean          default(FALSE), not null
#  clicked     :boolean          default(FALSE), not null
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

require 'spec_helper'

describe NotificationActivity do
  pending "add some examples to (or delete) #{__FILE__}"
end
