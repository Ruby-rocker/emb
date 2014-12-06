class MessageSerializer < ApplicationSerializer
  include ActionView::Helpers::TextHelper

  attributes :id, :body, :body_html, :unread, :created_at, :errors

  has_one :conversation
  has_one :user

  def unread
    object.unread?(current_user)
  end

  def body_html
    simple_format object.body
  end

end
