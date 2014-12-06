class CommentSerializer < ApplicationSerializer
  include ActionView::Helpers::TextHelper

  attributes :id,
      :body,
      :body_html,
      :created_at

  has_one :user
  has_one :commentable, polymorphic: true, embed: :ids, include: false

  def body_html
    simple_format object.body
  end

end
