class MediaPostSerializer < PostSerializer
  include ActionView::Helpers::TextHelper

  attributes :id,
    :title,
    :body,
    :body_html,
    :posted_at,
    :errors

  has_one :user
  has_one :event, embed: :ids, include: true
  has_many :attachments, embed: :ids, include: true
  has_many :comments, embed: :ids, include: true

  def body_html
    simple_format object.body
  end

  def comments
    object.comments.where(user_id: scope)
  end

end
