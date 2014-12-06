class Api::V1::MediaPostsController < Api::V1::BaseController

  before_filter :auth_only!

  def index
    if params[:ids] || params[:id]
      media_posts = (find_posts_by_ids(params[:ids]) || find_post_by_id(params[:id]))
      respond_with media_posts
    else
      render json: {}
    end
  end

  def show
    media_post = find_post_by_id(params[:id])
    respond_with media_post
  end

end
