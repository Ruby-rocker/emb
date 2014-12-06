# == Schema Information
#
# Table name: user_tags
#
#  id         :integer          not null, primary key
#  post_id    :integer          indexed
#  user_id    :integer          indexed
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserTag < ActiveRecord::Base
  belongs_to :post
  belongs_to :user
end
