class SignupSerializer < ActiveModel::Serializer

  attributes  :email,
              :username,
              :password,
              :first_name,
              :last_name,
              :errors,
              :auth_token

  def auth_token
    object.user.authentication_token
  end

end
