class Api::V1::FriendshipsController < Api::V1::BaseController

  before_filter :auth_only!

  def index
    friendships = Friendship.for_user(current_user).find(params[:ids])
    render json: friendships
  end

  def show
    friendships = Friendship.for_user(current_user).find(params[:id])
    render json: friendships
  end

  def create
    return missing_params if !valid_create_params?(params)

    friendship = Friendship.new()
    friendship.sender = current_user
    friendship.receiver = User.find(params[:friendship][:receiver_id])

    if friendship.save
      if friendship.receiver.email_on_friend_request
        UserMailer.delay.new_friend_request(friendship.id)
      end

      render json: friendship
    else
      render json: friendship, status: 422
    end
  end

  def update
    friendship = Friendship.for_user(current_user).find(params[:id])
    friendship.pending = false

    if friendship.save
      if friendship.approved?
        NewFriendshipFeedPopulatorWorker.perform_async(friendship.id)
      end

      render json: friendship
    else
      render json: friendship, status: 422
    end
  end

  def destroy
    friendship = Friendship.for_user(current_user).find(params[:id])

    if friendship.destroy
      EndedFriendshipFeedCleanupWorker.perform_async(friendship.sender_id, friendship.receiver_id)
      render json: friendship
    else
      render json: friendship, status: 422
    end
  end

  protected

    def valid_create_params?(params)
      return false if params[:friendship].blank?
      return false if params[:friendship][:receiver_id].blank?
      true
    end

end
