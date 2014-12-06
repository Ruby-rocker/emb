class ActivityPublisher

  attr_accessor :activity
  attr_accessor :fan_out_type
  attr_accessor :options

  def initialize(activity)
    @activity = activity
  end

  def publish(options = {})
    publish_to_primary(options)
    PublishActivityToExtendedWorker.perform_async(activity.id, options)
  end

  # notifies owner and immediate edges, eg:
  # new post notifies owner of post, new message notifies owner and recipient
  def publish_to_primary(options = {})
    @fan_out_type = :primary
    @options = options
    publish_activity
  end

  # notifies friends and other edges
  def publish_to_extended(options = {})
    @fan_out_type = :extended
    @options = options
    publish_activity
  end

  private

    def publish_activity
      if activity.trackable
        case activity.trackable_type
        when 'Post'
          process_post(activity)
        when 'Event'
          process_event(activity)
        when 'EventInvitaion'
          process_event_invitation(activity)
        when 'Comment'
          process_comment(activity)
        end
      end
    end

    def add_to_newsfeed(users, activity)
      unless @options[:exclude_newsfeed]
        users = [users] if !users.is_a?(Array)
        users.each do |user|
          unless user.newsfeed_activities.exists?(activity.id)
            user.newsfeed_activities << activity
          end
        end
      end
    end

    def add_to_userfeed(users, activity)
      unless @options[:exclude_userfeeds]
        users = [users] if !users.is_a?(Array)
        users.each do |user|
          unless user.userfeed_activities.exists?(activity.id)
            user.userfeed_activities << activity
          end
        end
      end
    end

    def add_to_notifications(users, activity)
      unless @options[:exclude_notifications]
        users = [users] if !users.is_a?(Array)
        users.each do |user|
          unless user.notifications.exists?(activity)
            notification_activity = user.notification_activities.new
            notification_activity.activity = activity
            notification_activity.save
          end
        end
      end
    end

    ##############################################################################
    ## Posts

    def process_post(activity)
      case activity.key
      when 'post.create'
        activity.transaction do
          activity.posted_at = activity.trackable.created_at
          activity.userfeed_posted_at = activity.trackable.posted_at
          activity.save

          process_new_post(activity)
          process_new_event_post(activity)
        end

      when 'post.mentioned'
        activity.transaction do
          activity.posted_at = activity.trackable.created_at
          activity.save
          process_new_mention(activity)
        end

      when 'post.tagged'
        activity.transaction do
          activity.posted_at = activity.trackable.created_at
          activity.save
          process_new_tag(activity)
        end
      end
    end

    def process_new_post(activity)
      post = activity.trackable

      if fan_out_type == :primary
        # add to the owner's feeds
        add_to_userfeed(activity.owner, activity)
        add_to_newsfeed(activity.owner, activity) unless post.is_private

      elsif fan_out_type == :extended
        unless post.is_private
          add_to_newsfeed(activity.owner.friends.all, activity)
        end
      end
    end

    def process_new_event_post(activity)
      # it's not possible to add private event posts right now so we don't need
      # to handle that case

      event = activity.trackable.event
      if event && event.user != activity.owner
        if fan_out_type == :primary
          # notify event owner
          add_to_notifications(event.user, activity)
          add_to_newsfeed(event.user, activity)
          if @options[:send_emails] && event.user.email_on_event_post
            UserMailer.new_event_post(activity.trackable_id).deliver
          end

        elsif fan_out_type == :extended
          # add to event attendees newsfeeds
          add_to_newsfeed(event.attendees, activity)
        end
      end
    end


    ##############################################################################
    ## Events

    def process_event(activity)
      case activity.key
      when 'event.create'
        activity.posted_at = activity.trackable.created_at
        activity.userfeed_posted_at = activity.trackable.created_at
        activity.save
        process_new_event(activity)

      when 'event.mentioned'
        activity.transaction do
          activity.posted_at = activity.trackable.created_at
          activity.save
          process_new_mention(activity)
        end
      end
    end

    def process_new_event(activity)
      activity.transaction do
        activity.posted_at = activity.trackable.created_at
        activity.save

        if fan_out_type == :primary
          # add to the owner's feeds
          add_to_userfeed(activity.owner, activity)
          add_to_newsfeed(activity.owner, activity)

        elsif fan_out_type == :extended
          # add to the owner's friends newsfeeds
          add_to_newsfeed(activity.owner.friends.all, activity)
        end
      end
    end


    ##############################################################################
    ## Event Invitations

    def process_event_invitation(activity)
      case activity.key
      when 'event_invitation.accept'
        activity.transaction do
          activity.posted_at = activity.created_at
          process_accepted_event_invitation(activity)
        end
      when 'event_invitation.decline'
        activity.transaction do
          activity.posted_at = activity.created_at
          process_declined_event_invitation(activity)
        end
      end
    end

    def process_accepted_event_invitation(activity)
      if fan_out_type == :extended
        # add to friends newsfeeds
        add_to_newsfeed(activity.owner.friends.all, activity)
      end
    end

    def process_declined_event_invitation(activity)
      if fan_out_type == :extended
        # remove from friends newsfeeds
        activity.owner.friends.all.each do |friend|
          activity = friend.newsfeed_activities.where(
            trackable_id: activity.trackable.event_id,
            key: 'event_invitation.accept'
          ).first

          friend.newsfeed_activities.delete(activity) if activity
        end
      end
    end

    ##############################################################################
    ## Comments

    def process_comment(activity)
      case activity.key
      when 'comment.create'
        activity.transaction do
          activity.posted_at = activity.trackable.created_at
          activity.save
          process_new_comment(activity)
        end

      when 'comment.mentioned'
        activity.transaction do
          activity.posted_at = activity.trackable.created_at
          activity.save
          process_new_mention(activity)
        end
      end
    end

    def process_new_comment(activity)
      if fan_out_type == :extended
        commentable = activity.trackable.commentable

        # notify commentable's owner unless self
        commentable_owner = commentable.user
        if commentable_owner != activity.owner
          add_to_notifications(commentable_owner, activity)
          if @options[:send_emails] && commentable_owner.email_on_comment
            if commentable.is_a?(Post)
              UserMailer.delay.new_post_comment(commentable_owner, activity.trackable.id)
            elsif commentable.is_a?(Attachment)
              UserMailer.delay.new_attachment_comment(commentable_owner, activity.trackable.id)
            end
          end
        end

        # notify other commenters
        users = commentable.commenters - [commentable_owner, activity.owner]
        add_to_notifications(users, activity)
      end
    end


    ##############################################################################
    ## Mentions

    def process_new_mention(activity)
      # we shouldn't notify users if they are mentioned:
      #   in a private post
      #   in a comment on a private post
      #   in a comment on an attachment in a private post

      is_private = activity.trackable.is_private?

      if fan_out_type == :extended && !is_private
        # notify mentioned user
        recipient = activity.recipient
        add_to_notifications(recipient, activity)
        if @options[:send_emails] && recipient.email_on_mention
          UserMailer.delay.new_mention(recipient.id, activity.owner_id, activity.trackable_type, activity.trackable_id)
        end
      end
    end


    ##############################################################################
    ## Tags

    def process_new_tag(activity)
      # we shouldn't notify users tagged in private posts

      is_private = activity.trackable.is_private?

      if fan_out_type == :extended && !is_private
        # notify tagged user
        recipient = activity.recipient
        add_to_notifications(recipient, activity)
        if @options[:send_emails] && recipient.email_on_tag
          UserMailer.delay.new_tag(recipient.id, activity.owner_id, activity.trackable_id)
        end
      end
    end

end
