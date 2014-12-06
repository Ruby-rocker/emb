class Api::V1::UserfeedActivitiesController < Api::V1::BaseController

  before_filter :auth_only!

  def index
    return missing_params if !valid_feed_params?(params)
    return unauthorised if !valid_user_ids.include?(params[:user_id].to_i)

    user = User.find(params[:user_id])
    date = params[:date] ? DateTime.parse(params[:date]) : Date.today
    #activities = user.userfeed_activities.for_userfeed_date(date).order('userfeed_posted_at DESC')
    #prev_date = user.userfeed_activities.last_before_userfeed_date(date).try(:userfeed_posted_at) || "none"
    #next_date = user.userfeed_activities.first_after_userfeed_date(date).try(:userfeed_posted_at) || "none"
    if (user.id == current_user.id)
      event_ids = (params[:check_private] == 'true' ? current_user.events.is_private.pluck(:id).uniq : current_user.events.is_public.pluck(:id).uniq)
      post_ids = (params[:check_private] == 'true' ? current_user.posts.is_private.pluck(:id).uniq : current_user.posts.is_public.pluck(:id).uniq)

      trackable_ids = (event_ids + post_ids)

      prev_date = current_user.userfeed_activities.last_before_userfeed_date_trackable(date, trackable_ids).try(:userfeed_posted_at) || "none"

      next_date = current_user.userfeed_activities.first_after_userfeed_date_trackable(date, trackable_ids).try(:userfeed_posted_at) || "none"
    else
      event_ids = (current_user.invited_events.pluck(:id) + user.events.is_public.pluck(:id)).uniq
      post_ids = (current_user.user_tags.pluck(:post_id) + user.posts.is_public.pluck(:id)).uniq
      # ids.each do |id|
      #   activities = activities.for_userfeed_date_friend(id)
      # end
      prev_date = user.userfeed_activities.last_before_userfeed_date(date).try(:userfeed_posted_at) || "none"
      next_date = user.userfeed_activities.first_after_userfeed_date(date).try(:userfeed_posted_at) || "none"
    end
    activities_events = user.activities.before_userfeed_date_friend_event(date).order('userfeed_posted_at DESC').find_all_by_trackable_id(event_ids)
    activities_posts = user.activities.before_userfeed_date_friend_post(date).order('userfeed_posted_at DESC').find_all_by_trackable_id(post_ids)
    activities = activities_events + activities_posts

    render json: activities,
        meta: { prev_date: prev_date, next_date: next_date },
        each_serializer: ActivitySerializer
  end

  private

    def valid_feed_params?(params)
      params[:user_id].present?
    end

end
