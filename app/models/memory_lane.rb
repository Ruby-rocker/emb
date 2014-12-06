class MemoryLane
  include Virtus.model
  include ActiveModel::Validations
  include ActiveModel::SerializerSupport

  attr_reader :id
  attr_reader :date
  attr_reader :user
  attr_reader :profile_version
  attr_reader :activities
  attr_reader :posts_count
  attr_reader :events_count

  def initialize(current_user, tz_offset = 0, user = nil)
    @id = Time.zone.now.to_i
    @activities = []

    tz_offset = tz_offset.to_i

    @user = user
    @user = current_user.friends.with_content.order('RANDOM()').first if !user

    if @user
      latest_possible_date = Time.zone.now.beginning_of_day + tz_offset.minutes
      @date = @user.userfeed_activities
          .where{userfeed_posted_at.lt my{latest_possible_date}}
          .select(:userfeed_posted_at)
          .order('RANDOM()')
          .first.try(:userfeed_posted_at)

      if @date
        Rails.logger.info "Memory lane date: #{@date}"
        adjusted_date = @date + tz_offset.minutes
        Rails.logger.info "Memory lane adjusted date: #{adjusted_date}"
        Rails.logger.info "Memory lane beginning_of_day: #{adjusted_date.beginning_of_day + -tz_offset.minute}"
        Rails.logger.info "Memory lane end_of_day: #{adjusted_date.end_of_day + -tz_offset.minute}"

        @activities = @user.userfeed_activities
          .for_userfeed_date(@date, tz_offset).limit(5) || []

        @posts_count = @user.userfeed_activities
          .for_userfeed_date(@date, tz_offset).where(key: 'post.create').count

        @events_count = @user.userfeed_activities
          .for_userfeed_date(@date, tz_offset).where(key: 'event.create').count

        @profile_version = @user.profile.version_for_date(@date)
      end
    end
  end
end
