class Api::V1::UsersController < Api::V1::BaseController

  def index
    #if params[:ids] || params[:id]
    if ids = params[:ids] || params[:id]
      users = User.confirmed.find(params[:ids] || params[:id])
      users = [users] if users && !users.is_a?(Array)
      render json: users
    elsif params[:username]
      user = User.confirmed.find(params[:username])
      render json: [user]
    elsif params[:socialMatches] && current_user
      connect_to_social_media
    elsif params[:search]
      if params[:friends]
        friend_ids = current_user.friend_ids
        users = User.simple_search(params[:search], friend_ids)
      else
        users = User.simple_search(params[:search])
      end
      render json: users
    else
      render json: {}
    end
  end

  def show
    user = User.confirmed.find(params[:id])
    respond_with user
  end

  def update
    # only replace these if we're actually given values and they are different
    [:email, :username, :password].each do |field|
      value = params[:user].delete(field)
      if value.present? && value != current_user[field]
        current_user.send("#{field}=", value)
      end
    end

    # remove anything we don't want that's passed through by ember data
    params[:user].delete(:profile_id)

    # everything else can be passed through as usual
    current_user.assign_attributes(params[:user])

    if current_user.save
      render json: current_user
    else
      render json: current_user, status: 422
    end
  end

protected
  def connect_to_social_media
    system_users = Hash.new
    user_match_ids = Array.new
    Profile.all.map{|e| system_users[e.full_name.downcase] = e.id}

    # Facebook connect and grab users
    f_auth = current_user.authentications.where("provider = ?", "facebook")
    if f_auth.present?
      fb_friends = FbGraph::User.me(f_auth.first.token).friends
      fb_friends.each do |fb_friend|
        if system_users.key?(fb_friend.raw_attributes['name'].downcase)
          user_match_ids << system_users[fb_friend.raw_attributes['name'].downcase]
        end
      end if fb_friends.present?
    end

    # Twitter connect and grab users
    t_auth = current_user.authentications.where("provider = ?", "twitter")
    if t_auth.present?
      client = Twitter::REST::Client.new do |config|
        config.consumer_key        = ENV["TWITTER_CONSUMER_KEY"]
        config.consumer_secret     = ENV["TWITTER_CONSUMER_SECRET"]
        config.access_token        = t_auth.first.token
        config.access_token_secret = t_auth.first.token_secret
      end
      tw_friends = client.friends.attrs[:users]
      tw_friends.each do |tw_friend|
        if system_users.key?(tw_friend[:name].downcase)
          user_match_ids << system_users[tw_friend[:name].downcase]
        end
      end if tw_friends.present?
    end

    if user_match_ids.blank?
      respond_with []
    else
      users = User.where("id in (?)", user_match_ids)
      respond_with users
    end
  end
end
