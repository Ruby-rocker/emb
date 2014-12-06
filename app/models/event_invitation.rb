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

class EventInvitation < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: :user

  belongs_to :event
  belongs_to :user

  attr_accessible :event_id, :user_id, :accepted, :acceptance_confirmed_at

  validates :user_id, uniqueness: { scope: :event_id,
      message: 'has already been invited' }

  scope :accepted, where(accepted: true)
  scope :declined, where{(accepted = false) && (acceptance_confirmed_at != nil)}
  scope :pending, where(accepted: false, acceptance_confirmed_at: nil)

end
