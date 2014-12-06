class Newsfeed
  include Virtus.model

  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include ActiveModel::SerializerSupport

  attr_reader :posts
  attr_reader :total_posts

  def initialize(user, options)
    page = options[:page] || 1
    per = options[:per] || 5
    friend_ids = user.friend_ids + [user.id]
    @total_posts = Post.where{user_id.in friend_ids}.count
    @posts = Post.where{user_id.in friend_ids}.order('created_at DESC').page(page).per(per)
  end

end
