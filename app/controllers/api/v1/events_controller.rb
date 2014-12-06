class Api::V1::EventsController < Api::V1::BaseController

  before_filter :auth_only!

  def index
    if ids = params[:ids]
      events = Event.where{(id.in ids) && (id.in my{valid_event_ids})}
      render json: events

    elsif params[:date]
      return missing_params if !valid_feed_params?(params)

      return unauthorised if !valid_user_ids.include?(params[:user_id].to_i)

      user = User.find(params[:user_id])
      date = params[:date] ? DateTime.parse(params[:date]) : Date.today
      if params[:date_status] == "true"
        events_date = DateTime.parse(params[:date]).to_date
        if user.equal?(current_user)
          activities = current_user.events.where('Date(start_time) = ?', events_date).order('start_time DESC')
        else
          activities = current_user.invited_events.where('Date(start_time) = ?', events_date).with_user(user.id).order('start_time DESC')
          public_activities = user.events.is_public.where('Date(start_time) = ?', events_date).order('start_time DESC')
          activities = (activities + public_activities).uniq
        end
      else
        month = params[:date] ? DateTime.parse(params[:date]).month : Date.today.month
        year = params[:date] ? DateTime.parse(params[:date]).year : Date.today.year
        if user.id.equal?(current_user.id)
          activities = current_user.events.where('extract(month from start_time) = ? AND extract(year from start_time) = ?', month, year).order('start_time DESC')
        else
          activities = current_user.invited_events.where('extract(month from start_time) = ? AND extract(year from start_time) = ?', month, year).order('start_time DESC')
          public_activities = user.events.is_public.where('extract(month from start_time) = ? AND extract(year from start_time) = ?', month, year).order('start_time DESC')
          activities = (activities + public_activities).uniq
        end
      end
      event_times = activities.map{|u| u.start_time.to_date}.uniq
      prev_date = date - 1.month || "none"
      next_date = date + 1.month || "none"

      render json: activities,
          meta: { prev_date: prev_date, next_date: next_date, event_times: event_times, user: user },
          each_serializer: EventSerializer
    elsif params[:user_id]
      user = User.where{id.in my{valid_user_ids}}.find(params[:user_id])
      if user.id.equal?(current_user.id)
        events = current_user.events.is_public.order('created_at DESC').limit(params[:limit])
      else
        events = current_user.invited_events.with_user(user.id).order('created_at DESC').limit(params[:limit])
        public_activities = user.events.is_public.order('start_time DESC')
        events = (events + public_activities).uniq
        # events = user.events.order('created_at DESC').limit(params[:limit])
      end
      render json: events
    end
  end

  def show
    event = Event.is_public.where{user_id.in my{valid_user_ids}}.find(params[:id])
    respond_with event
  end

  def create
    clean_ember_params!

    @event = current_user.events.build(params[:event])

    if @event.save
      render json: @event
    else
      render json: @event, status: 422
    end
  end

  def update
    @event = Event.find(params[:id])
    return unauthorized if @event.user != current_user

    clean_ember_params!

    if @event.update_attributes(params[:event])
      render json: @event
    else
      render json: @event, status: 422
    end
  end

  protected

    def clean_ember_params!
      return false if params[:event].blank?
      params[:event].delete(:user_id)
      params[:event].delete(:cover_photo_id)
    end

    def valid_feed_params?(params)
      params[:user_id].present?
    end


end
