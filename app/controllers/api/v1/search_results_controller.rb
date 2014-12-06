class Api::V1::SearchResultsController < Api::V1::BaseController

  before_filter :auth_only!, :only => [:show, :index]

  def index
    @search_result = SearchResult.new(params[:id], current_user.id, params[:chk_private])
    render :json => @search_result, :serializer => SearchResultSerializer
  end

  def show
    @search_result = SearchResult.new(params[:id], current_user.id, params[:chk_private])
    render :json => @search_result, :serializer => SearchResultSerializer
  end

  def search_result_record
    @search_result = SearchResult.new(params[:query], current_user.id, params[:chk_private])
    render :json => @search_result, :serializer => SearchResultSerializer
  end

  def password_validate
    user = User.find(params[:id])
    user_in_search = PrivatePublicSearch.find_by_email(user.email)
    result = user_in_search.valid_password?(params[:pass])
    render :json => result
  end

  def validate_with_user_password
    user = User.find(params[:id])
    result = user.valid_password?(params[:pass])
    render :json => result
  end

  def create_search_password
    user = User.find(params[:id])
    user_in_search = PrivatePublicSearch.find_by_email(user.email)
    result = false
    if user_in_search.blank?
      PrivatePublicSearch.create!({:email => user.email, :password => params[:pass], :password_confirmation => params[:pass]})
      result = true
    end
    render :json => result
  end

  def is_exist_in_search
    user = User.find(params[:id])
    user_in_search = PrivatePublicSearch.find_by_email(user.email)
    result = (user_in_search.nil?) ? true : false
    render :json => result
  end
end
