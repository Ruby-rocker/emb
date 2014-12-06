# == Schema Information
#
# Table name: likes
#
#  id            :integer          not null, primary key
#  user_id       :integer          indexed
#  likeable_id   :integer          indexed => [likeable_type]
#  likeable_type :string(255)      indexed => [likeable_id]
#  emotion_cd    :integer          indexed
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#

require 'spec_helper'

describe Like do
  pending "add some examples to (or delete) #{__FILE__}"
end
