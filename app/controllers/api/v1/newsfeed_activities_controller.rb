class Api::V1::NewsfeedActivitiesController < Api::V1::BaseController

  before_filter :auth_only!

  def index
    start_time = params[:start_time].present? ? DateTime.parse(params[:start_time]) : DateTime.now
    page = params[:page].present? ? params[:page].to_i : 1

    # Note: We don't need to perform any permissions checks here as the
    # ActivityPublisher ensures that we always have a clean feed. This method
    # is hit a lot so needs to be as fast and memory efficient as possible
    @activities = current_user.newsfeed_activities
      .where{posted_at <= start_time}
      .order('posted_at DESC').page(page).per(10)

    more_pages = current_user.newsfeed_activities.count - page * 10 > 0 ? 'yes' : 'no'
    meta = {
      page: page,
      more_pages: more_pages,
      start_time: start_time
    }

    respond_with @activities, each_serializer: ActivitySerializer, meta: meta
  end

end
