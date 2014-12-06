class SessionsController < Devise::SessionsController

  respond_to :json

  def create
    unless (params[:user][:email].present? && params[:user][:password].present?) || params[:auth_token].present?
      return missing_params
    end

    if params[:auth_token]
      resource = resource_from_auth_token
    else
      resource = resource_from_credentials
    end
    return invalid_credentials unless resource
    return confirmation_required unless resource.active_for_authentication?

    resource.update_tracked_fields!(request)
    resource.ensure_authentication_token!
    data = {
      user_token: resource.authentication_token,
      user_email: resource.email,
      user_id: resource.id
    }

    render json: data, status: 201
  end

  def destroy
    resource = resource_from_auth_headers
    resource.authentication_token = nil
    resource.save

    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name)
    render json: {}, status: 200
  end

  protected

    def resource_from_credentials
      data = { login: params[:user][:email] }
      if res = resource_class.find_for_database_authentication(data)
        if res.valid_password?(params[:user][:password])
          res
        end
      end
    end

    def resource_from_auth_headers
      authenticate_with_http_token do |token, options|
        return unless token && options['user_email']

        user = User.find_by_email(options['user_email'])

        if user && Devise.secure_compare(user.authentication_token, token)
          return user
        else
          invalid_credentials
        end
      end
    end

    def resource_from_auth_token
      token = params[:auth_token]
      resource_class.where(authentication_token: token).first
    end

    def missing_params
      warden.custom_failure!
      response = { message: 'Please fill in both "login" and "password" fields' }
      render json: response, status: 400
    end

    def invalid_credentials
      warden.custom_failure!
      response = { message: 'Incorrect login/password combination!' }
      render json: response, status: 401
    end

    def confirmation_required
      warden.custom_failure!
      render json: {message: 'confirmation required'}, status: 401
    end

end
