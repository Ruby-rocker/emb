class PasswordsController < Devise::PasswordsController

  def edit
    redirect_to "/home/reset_password?reset_password_token=#{params[:reset_password_token]}"
  end

  def update
    self.resource = resource_class.reset_password_by_token(resource_params)

    if resource.errors.empty?
      resource.unlock_access! if unlockable?(resource)
      render json: resource
    else
      render json: resource.errors.full_messages.to_sentence, status: 406
    end
  end

  protected

    def after_sending_reset_password_instructions_path_for(resource_name)
      '/home/sign_in'
    end

end
