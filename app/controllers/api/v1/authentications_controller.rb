class Api::V1::AuthenticationsController < Api::V1::BaseController

  before_filter :auth_only!

  def destroy
    authentication = current_user.authentications.find(params[:id])
    if authentication.destroy
      render json: {}
    else
      render json: authentication, status: 422
    end
  end

end
