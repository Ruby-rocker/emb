if ActiveRecord::Base.connection.table_exists? 'activities'
  PublicActivity::Activity.class_eval do

    has_and_belongs_to_many :newsfeed_users,
      class_name: 'User',
      join_table: :newsfeed_activities

    has_and_belongs_to_many :userfeed_users,
      class_name: 'User',
      join_table: :userfeed_activities

    belongs_to :activity_user,
      class_name: 'User'
    has_many :notification_activities
    has_many :notified_users,
      class_name: 'User',
      through: :notification_activities

    scope :unprocessed, where(processed: false)

    attr_accessor :status_attrs

    @publish_options = { send_emails: true }
    def self.publish_options
      @publish_options
    end
    def publish_options
      self.class.publish_options
    end

    after_create do
      ActivityPublisher.new(self).publish(publish_options)

      delete_from_feeds if key == 'post.destroy'
      delete_from_feeds if key == 'event.destroy'
    end

    after_destroy do |record|
      NotificationActivity.delete_all(['activity_id = ?', record.id])
    end

    def self.for_date(date, tz_offset = 0)
      adjusted_date = date + tz_offset.minutes
      beginning_of_day = adjusted_date.beginning_of_day + -tz_offset.minutes
      end_of_day = adjusted_date.end_of_day + -tz_offset.minutes
      where{(posted_at > beginning_of_day) & (posted_at < end_of_day)}
    end

    def self.for_userfeed_date(date, tz_offset = 0)
      adjusted_date = date + tz_offset.minutes
      beginning_of_day = adjusted_date.beginning_of_day + -tz_offset.minutes
      end_of_day = adjusted_date.end_of_day + -tz_offset.minutes
      where{
        (userfeed_posted_at > beginning_of_day) &
        (userfeed_posted_at < end_of_day)
      }
    end

    def self.before_userfeed_date_friend_event(date, tz_offset = 0)
      adjusted_date = date + tz_offset.minutes
      beginning_of_day = adjusted_date.beginning_of_day + -tz_offset.minutes
      end_of_day = adjusted_date.end_of_day + -tz_offset.minutes
      where{
        (userfeed_posted_at > beginning_of_day) &
        (userfeed_posted_at < end_of_day) & 
        (trackable_type == 'Event')
      }
    end

    def self.before_userfeed_date_friend_post(date, tz_offset = 0)
      adjusted_date = date + tz_offset.minutes
      beginning_of_day = adjusted_date.beginning_of_day + -tz_offset.minutes
      end_of_day = adjusted_date.end_of_day + -tz_offset.minutes
      where{
        (userfeed_posted_at > beginning_of_day) &
        (userfeed_posted_at < end_of_day) & 
        (trackable_type == 'Post')
      }
    end
    
    def self.for_userfeed_date_friend(in_event_id)
      where{(trackable_id == in_event_id)}
    end

    def self.before_date(date, tz_offset = 0)
      adjusted_date = date + tz_offset.minutes
      beginning_of_day = adjusted_date.beginning_of_day + -tz_offset.minutes
      where{(posted_at < beginning_of_day)}
    end

    def self.before_userfeed_date(date, tz_offset = 0)
      adjusted_date = date + tz_offset.minutes
      beginning_of_day = adjusted_date.beginning_of_day + -tz_offset.minutes
      where{(userfeed_posted_at < beginning_of_day)}
    end

    def self.before_userfeed_date_trackable(date, trackable_ids, tz_offset = 0)
      adjusted_date = date + tz_offset.minutes
      beginning_of_day = adjusted_date.beginning_of_day + -tz_offset.minutes
      where{(userfeed_posted_at < beginning_of_day) & (trackable_id.in(trackable_ids))}
    end

    def self.last_before_date(date, tz_offset = 0)
      before_date(date, tz_offset).order('posted_at DESC').limit(1).first
    end

    def self.last_before_userfeed_date(date, tz_offset = 0)
      before_userfeed_date(date, tz_offset)
        .order('userfeed_posted_at DESC').limit(1).first
    end

    def self.last_before_userfeed_date_trackable(date, trackable_ids, tz_offset = 0)
      before_userfeed_date_trackable(date, trackable_ids, tz_offset)
        .order('userfeed_posted_at DESC').limit(1).first
    end

    def self.after_date(date, tz_offset = 0)
      adjusted_date = date + tz_offset.minutes
      end_of_day = adjusted_date.end_of_day + -tz_offset.minutes
      where{(posted_at > end_of_day)}
    end

    def self.after_userfeed_date(date, tz_offset = 0)
      adjusted_date = date + tz_offset.minutes
      end_of_day = adjusted_date.end_of_day + -tz_offset.minutes
      where{(userfeed_posted_at > end_of_day)}
    end

    def self.after_userfeed_date_trackable(date, trackable_ids, tz_offset = 0)
      adjusted_date = date + tz_offset.minutes
      end_of_day = adjusted_date.end_of_day + -tz_offset.minutes
      where{(userfeed_posted_at > end_of_day) & (trackable_id.in(trackable_ids))}
    end

    def self.first_after_date(date, tz_offset = 0)
      after_date(date, tz_offset).order(:posted_at).limit(1).first
    end

    def self.first_after_userfeed_date(date, tz_offset = 0)
      after_userfeed_date(date, tz_offset).order(:userfeed_posted_at).limit(1).first
    end

    def self.first_after_userfeed_date_trackable(date, trackable_ids, tz_offset = 0)
      after_userfeed_date_trackable(date, trackable_ids, tz_offset)
      .order('userfeed_posted_at DESC').limit(1).first
      #after_userfeed_date_trackable(datetrackable_id.in(trackable_ids, tz_offset).order(:userfeed_posted_at).limit(1).first
    end

    private

      def delete_from_feeds
        activity_ids = PublicActivity::Activity.where(
          trackable_id: trackable_id,
          trackable_type: trackable_type
        ).pluck(:id)
        sql = "DELETE FROM \"newsfeed_activities\"
               WHERE \"newsfeed_activities\".\"activity_id\"
               IN (#{activity_ids.join(',')})"
        ActiveRecord::Base.connection.execute(sql)
        sql = "DELETE FROM \"userfeed_activities\"
               WHERE \"userfeed_activities\".\"activity_id\"
               IN (#{activity_ids.join(',')})"
        ActiveRecord::Base.connection.execute(sql)
      end

  end
end
