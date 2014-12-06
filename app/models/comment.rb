# == Schema Information
#
# Table name: comments
#
#  id               :integer          not null, primary key
#  body             :text
#  user_id          :integer          indexed
#  commentable_id   :integer          indexed => [commentable_type]
#  commentable_type :string(255)      indexed => [commentable_id]
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#

class Comment < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: :user

  belongs_to :user
  belongs_to :commentable, polymorphic: true, counter_cache: true

  attr_accessible :body

  validates_presence_of :body

  after_create :track_mentions

  delegate :is_private?, to: :commentable

  def mentioned_users
    body.scan(/@\[([^\]]+)\]\((\w+):(\d+)\)/).map{ |mention|
      User.find_by_id mention[2]
    }
  end

  def path
    commentable.path
  end

  private

    def track_mentions
      mentioned_users.each do |mentioned_user|
        self.create_activity :mentioned, recipient: mentioned_user
      end
    end

end
