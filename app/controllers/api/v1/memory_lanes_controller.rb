class Api::V1::MemoryLanesController < Api::V1::BaseController

  before_filter :auth_only!

  def index
    if !params[:user_id].empty?
      @user = User.find(params[:user_id])
    end

    memory_lane = MemoryLane.new(current_user, params[:tz_offset], @user)
    render json: [memory_lane]
  end

end
