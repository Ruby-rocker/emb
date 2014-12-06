class AttachmentSerializer < ApplicationSerializer

  attributes :id,
      :url,
      :mimetype,
      :media_type,
      :width,
      :height,
      :sub_type,
      :created_at,
      :comments_count,
      :like_counts,
      :errors

  has_one :user
  has_one :attachable, polymorphic: true, embed: :ids, include: true
  has_one :my_like, embed: :ids, include: true, root: :likes

  def include_my_like?
    current_user != nil
  end

  def my_like
    object.likes.where(user_id: current_user.id).first
  end

end
