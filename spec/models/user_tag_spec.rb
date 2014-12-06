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

require 'spec_helper'

describe UserTag do
  pending "add some examples to (or delete) #{__FILE__}"
end
