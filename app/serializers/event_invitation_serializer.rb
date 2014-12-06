class EventInvitationSerializer < ApplicationSerializer

  attributes :id,
      :accepted,
      :acceptance_confirmed_at,
      :created_at,
      :errors

  has_one :user
  has_one :event

end
