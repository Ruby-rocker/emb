class Api::V1::PostsController < Api::V1::BaseController

  before_filter :auth_only!

  def index
    if ids = params[:ids] || [params[:id]]
      posts = find_posts_by_ids(ids)
      render json: posts

    else
      render json: {}
    end
  end

  def show
    post = find_post_by_id(params[:id])
    respond_with post
  end

  def create
    # clean / capture ember-data supplied arguments
    params[:post].delete(:user_id)

    event_id = params[:post].delete(:event_id)

    if !tagged_users_are_valid?(params[:post])
      warden.custom_failure!
      render(json: { errors: "you can only tag your friends" }, status: 422) and return
    end

    post = current_user.posts.new(params[:post])

    if event_id
      if !invited_event_ids.include?(event_id.to_i)
        warden.custom_failure!
        render(json: { errors: "you're not allowed to post to that event" }, status: 422) and return
      end

      event = Event.find(event_id)
      post.event = event
    end

    if post.save
      render json: post, status: 201, serializer: PostLightSerializer
    else
      warden.custom_failure!
      render json: post, status: 422, serializer: PostLightSerializer
    end
  end

  def search
    @posts = Post.search do
      keywords params[:query]
    end.results

    render json: @posts
  end

  private

    def tagged_users_are_valid?(post_params)
      if post_params[:tagged_user_ids]
        user_ids = post_params[:tagged_user_ids].map(&:to_i)
        friend_ids = current_user.friend_ids
        (user_ids - friend_ids).empty?
      else
        true
      end
    end
end
