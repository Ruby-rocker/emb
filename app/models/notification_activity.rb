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

class NotificationActivity < ActiveRecord::Base

  belongs_to :user
  belongs_to :activity, class_name: 'PublicActivity::Activity'

  scope :clicked, where(clicked: true)
  scope :read, where(read: true)
  scope :unread, where(read: false)

end
