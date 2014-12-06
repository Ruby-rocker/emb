# == Schema Information
#
# Table name: posts
#
#  id               :integer          not null, primary key
#  title            :string(255)
#  body             :text
#  posted_at        :datetime
#  user_id          :integer
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  event_id         :integer          indexed
#  is_private       :boolean          default(FALSE)
#  total_like_count :integer          default(0), not null
#  like_counts      :text
#  comments_count   :integer          default(0), not null
#

class Post < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: :user

  belongs_to :user
  belongs_to :event
  has_many :attachments, as: :attachable, dependent: :destroy
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :commenters, class_name: 'User', through: :comments, source: :user
  has_many :likes, as: :likeable, dependent: :destroy
  has_many :user_tags, dependent: :destroy
  has_many :tagged_users, through: :user_tags, source: :user

  serialize :like_counts

  attr_accessible :title, :body, :posted_at, :is_private, :tagged_user_ids

  before_validation :ensure_posted_at
  before_save :ensure_no_private_posts_in_events
  after_create :track_mentions
  after_create :track_tags

  # TODO: removed to allow asynchronous attachment creation.
  #       add back when ember-data supports embedded records
  # validates :body, presence: true, if: :body_required?

  scope :standard, where{event_id == nil}
  scope :in_event, where{event_id != nil}

  scope :is_public, where(is_private: false)
  scope :is_private, where(is_private: true)

  searchable do
    integer :id, :multiple => true
    integer :user_id
    boolean :is_private
    text :title, :body, :more_like_this => true
  end

  def self.attachment_ids
    where("posts.id in (?)", select("posts.id").joins("INNER JOIN attachments ON posts.id=attachments.attachable_id"))
  end

  def self.media_post_search(query, current_user, chk_private)
    if query.present?
      query = query.downcase
      joins(:attachments).where("((lower(posts.title) like '%#{query}%' OR lower(posts.body) like '%#{query}%') AND posts.user_id = ? AND posts.is_private = ?)", current_user, chk_private)
    end
  end

  def self.for_date(date)
    where{(created_at > date.beginning_of_day) & (created_at < date.end_of_day)}
  end

  def self.before_date(date)
    where{(created_at < date.beginning_of_day)}
  end

  def self.last_before_date(date)
    before_date(date).order('created_at DESC').limit(1).first
  end

  def self.after_date(date)
    where{(created_at > date.end_of_day)}
  end

  def self.first_after_date(date)
    after_date(date).order(:created_at).limit(1).first
  end

  def mentioned_users
    return [] if !body
    body.scan(/@\[([^\]]+)\]\((\w+):(\d+)\)/).map{ |mention|
      User.find_by_id mention[2]
    }
  end

  def path
    if event_id
      "/event/#{event_id}/posts"
    else
      "/post/#{id}"
    end
  end

  private

    def ensure_posted_at
      if !posted_at.present?
        self.posted_at = Time.zone.now
      end
    end

    def ensure_no_private_posts_in_events
      if event.present?
        self.is_private = false
      end
    end

    def body_required?
      attachments.empty? ? true : false
    end

    def track_mentions
      mentioned_users.each do |mentioned_user|
        self.create_activity :mentioned, recipient: mentioned_user
      end
    end

    def track_tags
      tagged_users.each do |tagged_user|
        self.create_activity :tagged, recipient: tagged_user
      end
    end

end
