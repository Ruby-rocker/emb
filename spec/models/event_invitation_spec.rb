# == Schema Information
#
# Table name: event_invitations
#
#  id                      :integer          not null, primary key
#  event_id                :integer
#  user_id                 :integer
#  accepted                :boolean          default(FALSE), not null
#  acceptance_confirmed_at :datetime
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#

require 'spec_helper'

describe EventInvitation do
  pending "add some examples to (or delete) #{__FILE__}"
end
