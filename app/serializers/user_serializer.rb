class UserSerializer < ApplicationSerializer

  attributes :id,
      :username,
      :email,
      :errors,
      :profile_photo_count,
      :cover_photo_count,
      :general_photo_count,
      :email_on_friend_request,
      :email_on_comment,
      :email_on_like,
      :email_on_event_invite,
      :email_on_event_post,
      :email_on_message,
      :email_on_mention,
      :email_on_tag

  has_many :authentications, embed: :ids, include: true
  has_one  :profile, embed: :ids, include: true
  has_many :friends, class_name: 'User'
  has_many :sent_friendships
  has_many :received_friendships

  def filter(keys)
    include_if_self = [
      :authentications,
      :email,
      :sent_friendships,
      :received_friendships,
      :email_on_friend_request,
      :email_on_comment,
      :email_on_like,
      :email_on_event_invite,
      :email_on_event_post,
      :email_on_message,
      :email_on_mention,
      :email_on_tag
    ]

    keys.delete!(include_if_self) if !is_self?

    keys.push(:email) if object.new_record?
  end

  private

    def is_self?
      @is_self == nil ? @is_self = (scope == object) : @is_self
    end

    def is_self_or_friend?
      if @is_self_or_friend == nil
        @is_self_or_friend = (is_self? || (scope && scope.friends_with?(object)))
      else
        @is_self_or_friend
      end
    end

end
