class Post < ActiveRecord::Base
  has_many :likes, as: :likeable
  serialize :like_counts
end

class Attachment < ActiveRecord::Base
  has_many :likes, as: :likeable
  serialize :like_counts
end

class Like < ActiveRecord::Base
  as_enum :emotion, love: 1, happy: 2, sad: 3, laugh: 4, wow: 5, inspire: 6
  belongs_to :likeable, polymorphic: true

  def self.counts_for_likeable(likeable)
    counts = {}
    Like.emotions.each do |name, id|
      count = likeable.likes.where(emotion_cd: id).count
      counts[id] = count
    end
    counts
  end
end

class AddLikeCountCacheColumns < ActiveRecord::Migration
  def up
    add_column :posts, :total_like_count, :integer, null: false, default: 0
    add_column :posts, :like_counts, :text

    Post.reset_column_information

    Post.all.each do |post|
      post.total_like_count = post.likes.count
      post.like_counts = Like.counts_for_likeable(post)
      post.save
    end


    add_column :attachments, :total_like_count, :integer, null: false, default: 0
    add_column :attachments, :like_counts, :text

    Attachment.reset_column_information

    Attachment.all.each do |attachment|
      attachment.total_like_count = attachment.likes.count
      attachment.like_counts = Like.counts_for_likeable(attachment)
      attachment.save
    end
  end

  def down
    remove_column :posts, :total_like_count
    remove_column :posts, :like_counts
    remove_column :attachments, :total_like_count
    remove_column :attachments, :like_counts
  end
end
