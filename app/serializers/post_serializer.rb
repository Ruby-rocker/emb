class PostSerializer < ApplicationSerializer
  include ActionView::Helpers::TextHelper

  attributes :id,
    :title,
    :body,
    :body_html,
    :posted_at,
    :is_private,
    :comments_count,
    :like_counts,
    :links,
    :errors

  has_one :user
  has_one :event, embed: :ids, include: true
  has_many :attachments, embed: :ids, include: true, serializer: AttachmentLightSerializer
  has_one :my_like, embed: :ids, include: true, root: :likes
  has_many :tagged_users

  def body_html
    simple_format object.body
  end

  def include_my_like?
    current_user != nil
  end

  def my_like
    object.likes.where(user_id: current_user.id).first
  end

  def links
    {
      likes: "/api/v1/likes/?like[likeable_type]=#{object.class}&like[likeable_id]=#{object.id}"
    }
  end

end
