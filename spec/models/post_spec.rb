# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  body             :text
#  posted_at        :datetime
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  event_id         :integer          indexed
#  is_private       :boolean          default(FALSE)
#  total_like_count :integer          default(0), not null
#  like_counts      :text
#  comments_count   :integer          default(0), not null
#

require 'spec_helper'

describe Post do
  pending "add some examples to (or delete) #{__FILE__}"
end
