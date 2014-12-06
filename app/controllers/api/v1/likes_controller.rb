class Api::V1::LikesController < Api::V1::BaseController

  before_filter :auth_only!
  before_filter :load_likeable, only: [:index, :create]

  def index
    likes = @likeable.likes
    render json: likes
  end

  def create
    like = @likeable.likes.new(params[:like])
    like.user = current_user

    if like.save
      render json: like, status: 201
    else
      render json: like, status: 422
    end
  end

  def update
    params[:like].delete(:likeable_type)
    params[:like].delete(:likeable_id)

    like = current_user.likes.find(params[:id])
    if like.update_attributes(params[:like])
      render json: like
    else
      render json: like, status: 422
    end
  end

  def destroy
    like = current_user.likes.find(params[:id])
    if like.destroy
      render json: {}
    else
      render json: like, status: 422
    end
  end

  private

    def load_likeable
      resource = params[:like].delete(:likeable_type)
      id = params[:like].delete(:likeable_id)
      @likeable = resource.singularize.classify.constantize.find(id)
    end

end
