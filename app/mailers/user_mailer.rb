class UserMailer < ActionMailer::Base

  default from: ENV['DEFAULT_FROM_ADDRESS']

  def new_friend_request(friendship_id)
    friendship = Friendship.find(friendship_id)
    @receiver = friendship.receiver
    @sender = friendship.sender
    @url = site_url + @sender.path

    subject = "#{@sender.profile.full_name} wants to be your friend"
    mail(to: @receiver.email, subject: subject)
  end

  def new_event_invite(event_invite_id)
    event_invite = EventInvitation.find(event_invite_id)
    @user = event_invite.user
    @event = event_invite.event
    @inviter = @event.user
    @url = site_url + @event.path

    subject = "#{@inviter.profile.full_name} has invited you to their event: #{@event.title}"
    mail(to: @user.email, subject: subject)
  end

  def new_event_post(post_id)
    post = Post.find(post_id)
    @event = post.event
    @sender = post.user
    @receiver = @event.user
    @url = site_url + post.path

    subject = "#{@sender.full_name} has posted to your event"
    mail(to: @receiver.email, subject: subject)
  end

  def new_post_comment(receiver_id, comment_id)
    @receiver = User.find(receiver_id)
    comment = Comment.find(comment_id)
    @sender = comment.user
    post = comment.commentable
    @event = post.event if post.event
    @url = site_url + post.path

    subject = "#{@sender.full_name} has commented on your post"
    mail(to: @receiver.email, subject: subject)
  end

  def new_attachment_comment(receiver_id, comment_id)
    @receiver = User.find(receiver_id)
    comment = Comment.find(comment_id)
    @sender = comment.user
    attachment_id = comment.commentable_id
    attachment = Attachment.find(attachment_id)
    attachable = attachment.attachable

    if attachable.is_a?(Profile)
      @commentable_type = "Profile Photo"
    elsif attachable.is_a?(Post)
      @commentable_type = "Photo"
      @event = attachable.event
    end

    @url = site_url + attachment.path

    subject = "#{@sender.full_name} has commented on your #{@commentable_type.downcase}"
    mail(to: @receiver.email, subject: subject)
  end

  def new_message(recipient_id, message_id)
    @recipient = User.find(recipient_id)
    message = Message.find(message_id)
    @sender = message.user
    @url = "#{site_url}/messages/#{message.conversation_id}"

    subject = "#{@sender.full_name} has sent you message"
    mail to: @recipient.email, subject: subject
  end

  def new_mention(recipient_id, sender_id, content_type, content_id)
    @recipient = User.find(recipient_id)
    @sender = User.find(sender_id)
    @content_type = text_for_content_type(content_type)
    content = content_type.classify.constantize.find(content_id)
    @url = site_url + content.path

    subject = "#{@sender.full_name} has mentioned you on Yostalgia"
    mail to: @recipient.email, subject: subject
  end

  def new_tag(recipient_id, sender_id, post_id)
    @recipient = User.find(recipient_id)
    @sender = User.find(sender_id)
    post = Post.find(post_id)
    @url = site_url + post.path

    subject = "#{@sender.full_name} has tagged you on Yostalgia"
    mail to: @recipient.email, subject: subject
  end

  private

    def site_url
      "http://#{default_url_options[:host]}"
    end

    def default_url_options
      ActionMailer::Base.default_url_options
    end

    def text_for_content_type(content_type)
      case content_type
      when 'Post'
        'a post'
      when 'Event'
        'an event'
      when 'Comment'
        'a comment'
      end
    end

end
