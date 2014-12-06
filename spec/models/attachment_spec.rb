# == Schema Information
#
# Table name: attachments
#
#  id               :integer          not null, primary key
#  filepicker_url   :string(255)
#  s3_key           :string(255)
#  filename         :string(255)
#  mimetype         :string(255)
#  filesize         :integer
#  media_type       :string(255)
#  user_id          :integer          indexed
#  attachable_id    :integer          indexed => [attachable_type]
#  attachable_type  :string(255)      indexed => [attachable_id]
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  width            :integer
#  height           :integer
#  sub_type         :string(255)      indexed
#  total_like_count :integer          default(0), not null
#  like_counts      :text
#  comments_count   :integer          default(0), not null
#

require 'spec_helper'

describe Attachment do
  pending "add some examples to (or delete) #{__FILE__}"
end
