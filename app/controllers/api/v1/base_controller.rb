class Api::V1::BaseController < ApplicationController

  respond_to :json
  before_filter :default_json
  before_filter :authenticate_user_from_token!

  protected

    def default_json
      request.format = :json if params[:format].nil?
    end

    def authenticate_user_from_token!
      authenticate_with_http_token do |token, options|
        user = User.find_by_email(options['user_email'])
        if user && Devise.secure_compare(user.authentication_token, token)
          sign_in user, store: false
        end
      end
    end

    def auth_only!
      if !user_signed_in?
        render json: {}, status: 401
      end
    end

    def unauthorized
      warden.custom_failure!
      render json: {}, status: 401
    end

    def missing_params
      warden.custom_failure!
      render json: {}, status: 400
    end

    ### universal find methods ###

    def valid_user_ids
      @valid_user_ids ||= current_user.friend_ids + [current_user.id]
    end

    def invited_event_ids
      if !@invited_event_ids
        own_event_ids = current_user.events.pluck(:id)
        invited_event_ids = current_user.invited_events.pluck(:id)
        @invited_event_ids = own_event_ids + invited_event_ids
      else
        @invited_event_ids
      end
    end

    def valid_event_ids
      if !@valid_event_ids
        invited_event_ids = current_user.invited_events.pluck(:id)
        mine_and_public_event_ids = Event.is_public
          .where{user_id.in my{valid_user_ids}}.pluck(:id)
        @valid_event_ids = (invited_event_ids + mine_and_public_event_ids).uniq
      else
        @valid_event_ids
      end
    end

    def find_post_by_id(id)
      Post.where{
        (user_id.in my{valid_user_ids}) |
        (event_id.in my{valid_event_ids})
      }.find(id)
    end

    def find_posts_by_ids(ids)
      Post.where{
        (id.in my{ids}) &
        (
          (user_id.in my{valid_user_ids}) |
          (event_id.in my{valid_event_ids})
        )
      }
    end

    def find_attachment_by_id(id)
      Attachment.where{ user_id.in my{valid_user_ids} }.find(id)
    end

end
