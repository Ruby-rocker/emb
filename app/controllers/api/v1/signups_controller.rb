class Api::V1::SignupsController < Api::V1::BaseController

  def create
    return missing_params if !valid_create_params?(params)

    @signup = Signup.new(params[:signup])

    if @signup.save
      @signup.user.ensure_authentication_token!
      render json: @signup, status: 201
    else
      warden.custom_failure!
      render json: @signup, status: 422
    end
  end

  # functions below are not handled through ember-data

  def check_email
    return missing_params unless params[:email]
    render json: { available: User.email_available?(params[:email]) }
  end

  def check_username
    return missing_params unless params[:username]
    validator = UsernameValidator.new(params[:username])
    if !validator.valid_format?
      render json: { errors: validator.errors }
    else
      render json: { available: User.username_available?(params[:username]) }
    end
  end

  protected

    def valid_create_params?(params)
      return false if params[:signup].blank?

      required_params = %w(email username first_name last_name)
      required_params.each do |param|
        return false if params[:signup][param].blank?
      end

      return true
    end

end
