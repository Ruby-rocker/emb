class EventSerializer < ApplicationSerializer
  include ActionView::Helpers::TextHelper

  attributes :id,
    :title,
    :body,
    :body_html,
    :start_time,
    :end_time,
    :location,
    :is_private,
    :created_at,
    :errors

  has_one :user
  has_one :cover_photo, class_name: 'Attachment', embed: :ids, include: true
  has_many :event_invitations, embed: :ids, include: true
  has_many :posts

  def body_html
    simple_format object.body
  end

end
