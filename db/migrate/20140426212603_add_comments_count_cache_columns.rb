class Post < ActiveRecord::Base
  has_many :comments, as: :commentable
end

class Attachment < ActiveRecord::Base
  has_many :comments, as: :commentable
end

class Comment < ActiveRecord::Base
  belongs_to :commentable, polymorphic: true, counter_cache: true
end

class AddCommentsCountCacheColumns < ActiveRecord::Migration
  def up
    add_column :posts, :comments_count, :integer, null: false, default: 0
    add_column :attachments, :comments_count, :integer, null: false, default: 0

    Post.reset_column_information
    Post.all.each do |post|
      post.update_column :comments_count, post.comments.count
    end

    Attachment.reset_column_information
    Attachment.all.each do |attachment|
      attachment.update_column :comments_count, attachment.comments.count
    end
  end

  def down
    remove_column :posts, :comments_count
    remove_column :attachments, :comments_count
  end
end
