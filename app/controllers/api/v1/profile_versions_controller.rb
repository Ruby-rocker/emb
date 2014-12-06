class Api::V1::ProfileVersionsController < Api::V1::BaseController

  def index
    return missing_params if !valid_find_params

    profile = Profile.find(params[:profile_id])
    profile_version = profile.version_for_date(DateTime.parse(params[:date]))

    render json: [profile_version], each_serializer: ProfileVersionSerializer
  end

  protected

    def valid_find_params
      params[:profile_id] && params[:date]
    end

end
