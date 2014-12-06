class OmniauthCallbacksController < Devise::OmniauthCallbacksController

  # TODO: refactor!

  def all
    auth = request.env['omniauth.auth']
    authentication = Authentication.find_by_provider_and_uid(auth['provider'], auth['uid'])
    email_match_user = User.find_by_email(auth.try(:info).try(:email))

    # this is necessary as we're not signed in by typical Devise routines
    if auth_token = cookies[:oauth_auth_token]
      cookies.delete :oauth_auth_token
      current_user = User.find_by_authentication_token(auth_token)
    end

    if authentication
      # account has already been linked
      user = authentication.user
      redirect_to "/newsfeed?auth_token=#{user.authentication_token}&remember=1"

    elsif current_user
      # user is already logged in, so we should link the account
      token = auth['credentials'].token
      token_secret = auth['credentials'].secret

      current_user.authentications.create!(
        provider: auth['provider'],
        uid: auth['uid'],
        token: token,
        token_secret: token_secret
      )

      flash[:success] = "Your #{auth['provider'].titleize} account has been successfully linked"
      if request.env['omniauth.origin']
        redirect_to request.env['omniauth.origin']
      else
        redirect_to "/"
      end

    elsif email_match_user
      token = auth['credentials'].token
      token_secret = auth['credentials'].secret

      email_match_user.authentications.create!(
        provider: auth['provider'],
        uid: auth['uid'],
        token: token,
        token_secret: token_secret
      )

      email_match_user.ensure_authentication_token!
      email_match_user.confirm!

      # TODO: method to display flash messages after app load
      flash[:success] = "Your #{auth['provider'].titleize} account has been successfully linked"
      redirect_to "/newsfeed?auth_token=#{email_match_user.authentication_token}&remember=1"

    else
      method_name = "new_#{auth['provider']}_auth".downcase
      self.send(method_name, auth) if self.respond_to?(method_name)
    end
  end

  alias_method :facebook, :all
  alias_method :twitter, :all


  def new_twitter_auth(auth)
    auth.delete(:extra)
    auth = auth.to_hash
    redirect_to "/signup/twitter?auth=#{URI.encode(auth.to_hash.to_json)}"
  end

  def new_facebook_auth(auth)
    user = User.from_omniauth(auth)
    user.ensure_authentication_token!
    redirect_to "/signup/step_2?auth_token=#{user.authentication_token}&remember=1"
  end

  def failure
    if request.env['omniauth.origin']
      redirect_to request.env['omniauth.origin']
    else
      redirect_to '/home/sign_in'
    end
  end

end
