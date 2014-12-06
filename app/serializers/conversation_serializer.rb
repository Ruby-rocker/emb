class ConversationSerializer < ApplicationSerializer

  attributes :id,
      :created_at,
      :updated_at,
      :display_user_id,
      :preview_text,
      :unread,
      :errors

  has_many :users

  def display_user_id
    message = object.messages
      .where{user_id.not_eq my{current_user.id}}
      .order('created_at DESC')
      .first

    user = message.try(:user) || object.users.where{id.not_eq my{current_user.id}}.first
    user.id
  end

  def preview_text
    object.messages.order('created_at DESC').first.try(:body)
  end

  def created_at
    object.messages.order('created_at ASC').first.try(:created_at)
  end

  def unread
    if object.respond_to? :unread
      object.unread
    else
      object.unread?(current_user)
    end
  end

end
