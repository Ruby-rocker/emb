class Api::V1::CommentsController < Api::V1::BaseController

  before_filter :auth_only!
  before_filter :load_commentable, only: :create

  def index
    if params[:post_id]
      post = find_post_by_id(params[:post_id])
      if post
        render json: post.comments
      end
    elsif params[:attachment_id]
      attachment = find_attachment_by_id(params[:attachment_id])
      if attachment
        render json: attachment.comments
      end
    end
  end

  def create
    params[:comment].delete(:user_id)

    comment = @commentable.comments.new(params[:comment])
    comment.user = current_user
    if comment.save
      render json: comment, status: 201
    else
      render json: comment, status: 422
    end
  end

  def destroy
    comment = current_user.comments.find(params[:id])
    if comment.destroy
      render json: {}
    else
      render json: comment, status: 422
    end
  end

  private

    def load_commentable
      resource = params[:comment].delete(:commentable_type)
      id = params[:comment].delete(:commentable_id)
      @commentable = resource.singularize.classify.constantize.find(id)
    end

end
