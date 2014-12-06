class SearchResult
  include Virtus.model
  include ActiveModel::SerializerSupport

  attr_reader :id
  attr_reader :users
  attr_reader :posts
  attr_reader :media_posts
  attr_reader :events

  def initialize(query, current_user_id, chk_private=false)
    @id = query
    chk_private = (chk_private == "true") ? true : false
    count = User.count
    @user_search = User.search do
      fulltext query do
        query_phrase_slop 1
      end
      without :confirmed_at, nil
      paginate :page => 1, :per_page => count
    end
    @users = @user_search.results

    @media_posts = Post.media_post_search(query, current_user_id, chk_private).uniq
    ids = @media_posts.map(&:id)
    count = Post.count
    @post_search = Post.search do
      fulltext query do
        query_phrase_slop 1
      end
      without(:id, ids)
      with(:user_id, current_user_id)
      with(:is_private, chk_private)
      paginate :page => 1, :per_page => count
    end
    @posts = @post_search.results
    count = Event.count
    @events_search = Event.search do
      fulltext query do
        query_phrase_slop 1
      end
      with(:user_id, current_user_id)
      with(:is_private, chk_private)
      paginate :page => 1, :per_page => count
    end
    @events = @events_search.results
  end
end
