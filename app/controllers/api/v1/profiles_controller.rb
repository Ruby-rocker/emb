class Api::V1::ProfilesController < Api::V1::BaseController

  before_filter :auth_only!, only: :update

  def show
    @profile = Profile.find(params[:id])
    respond_with @profile
  end

  def update
    @profile = Profile.find(params[:id])
    return unauthorized unless @profile.user == current_user

    params[:profile].delete(:user_id)
    params[:profile].delete(:photo_id)

    if @profile.update_attributes(params[:profile])
      render json: @profile
    else
      render json: @profile, status: 422
    end
  end

end
