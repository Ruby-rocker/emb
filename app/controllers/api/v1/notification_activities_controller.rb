class Api::V1::NotificationActivitiesController < Api::V1::BaseController

  before_filter :auth_only!

  def index
    if params[:ids]
      activities = current_user.notifications.includes(:trackable).find(params[:ids])
      respond_with activities, each_serializer: ActivitySerializer
    else
      page = params[:page].present? ? params[:page].to_i : 1
      limit = params[:limit].present? ? params[:limit].to_i : 10
      timestamp = DateTime.parse(params[:timestamp])

      activities = current_user.notifications
          .includes(:trackable)
          .where('posted_at < ?', timestamp)
          .order('posted_at DESC')
          .page(page)
          .per(limit)

      total = current_user.notifications.count
      more_pages = total - page * limit > 0 ? 'yes' : 'no'
      meta = { page: page, more_pages: more_pages, total: total }

      respond_with activities, each_serializer: ActivitySerializer, meta: meta
    end
  end

  def update
    notification_activity = current_user.notification_activities.find_by_activity_id(params[:id])
    notification_activity.read = params[:notification_activity][:read]
    notification_activity.clicked = params[:notification_activity][:clicked]
    if notification_activity.save
      activity = notification_activity.activity
      activity.status_attrs = {
        read: notification_activity.read,
        clicked: notification_activity.clicked
      }
      render json: activity, serializer: ActivitySerializer, root: :notification_activity
    else
      render json: notification_activity.activity, status: 422, serializer: ActivitySerializer, root: :notification_activity
    end
  end

end
