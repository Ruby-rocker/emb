# == Schema Information
#
# Table name: events
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  title      :string(255)
#  body       :text
#  start_time :datetime
#  end_time   :datetime
#  location   :string(255)
#  is_private :boolean          default(FALSE), not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Event < ActiveRecord::Base
  include PublicActivity::Model
  tracked owner: :user

  belongs_to :user
  has_many :posts, dependent: :destroy
  has_one :cover_photo, class_name: 'Attachment', as: :attachable,
    conditions: { sub_type: 'event_photo' },
    dependent: :destroy
  has_many :event_invitations, dependent: :destroy

  has_many :invitees, through: :event_invitations,
    class_name: 'User',
    source: :user

  has_many :attendees, through: :event_invitations,
      class_name: 'User',
      source: :user,
      conditions: ['event_invitations.accepted = ?', true]


  attr_accessible :title, :body, :start_time, :end_time, :location, :is_private

  validates :title, presence: true
  validates :body, presence: true
  validates :start_time, presence: true

  validate :end_time_is_later_than_start_time, if: "end_time.present?"

  after_create :track_mentions

  scope :is_public, where(is_private: false)
  scope :is_private, where(is_private: true)
  scope :with_user, ->(user_id) { where(:user_id => user_id) }

  searchable do
    integer :id, :multiple => true
    integer :user_id
    boolean :is_private
    text :title, :body, :location, :more_like_this => true
  end

  #def self.search(query)
  #  if query.present?
  #    query = query.downcase
  #    where("(lower(title) like '%#{query}%' OR lower(body) like '%#{query}%' OR lower(location) like '%#{query}%')")
  #  end
  #end
  def mentioned_users
    body.scan(/@\[([^\]]+)\]\((\w+):(\d+)\)/).map{ |mention|
      User.find_by_id mention[2]
    }
  end

  def path
    "/event/#{id}"
  end

  private

    def track_mentions
      mentioned_users.each do |mentioned_user|
        self.create_activity :mentioned, recipient: mentioned_user
      end
    end

    def end_time_is_later_than_start_time
      if end_time < start_time
        errors.add(:end_time, 'must be later than the events starting time')
      end
    end
end
