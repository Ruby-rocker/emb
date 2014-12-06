# == Schema Information
#
# Table name: users
#
#  id                      :integer          not null, primary key
#  email                   :string(255)      default(""), not null, indexed
#  encrypted_password      :string(255)      default(""), not null
#  reset_password_token    :string(255)      indexed
#  reset_password_sent_at  :datetime
#  remember_created_at     :datetime
#  sign_in_count           :integer          default(0)
#  current_sign_in_at      :datetime
#  last_sign_in_at         :datetime
#  current_sign_in_ip      :string(255)
#  last_sign_in_ip         :string(255)
#  confirmation_token      :string(255)      indexed
#  confirmed_at            :datetime
#  confirmation_sent_at    :datetime
#  unconfirmed_email       :string(255)
#  authentication_token    :string(255)      indexed
#  username                :string(255)      indexed
#  username_lower          :string(255)      indexed
#  email_lower             :string(255)      indexed
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  is_admin                :boolean          default(FALSE), not null
#  email_on_friend_request :boolean          default(TRUE), not null
#  email_on_comment        :boolean          default(TRUE), not null
#  email_on_like           :boolean          default(TRUE), not null
#  email_on_event_invite   :boolean          default(TRUE), not null
#  email_on_event_post     :boolean          default(TRUE), not null
#  email_on_message        :boolean          default(TRUE), not null
#  email_on_mention        :boolean          default(TRUE), not null
#  email_on_tag            :boolean          default(TRUE), not null
#

class User < ActiveRecord::Base
  include PublicActivity::Model
  activist

  extend FriendlyId
  friendly_id :username

  acts_as_reader # 'unread' gem

  attr_accessible :username, :email, :password, :remember_me,
      :email_on_friend_request,
      :email_on_comment,
      :email_on_like,
      :email_on_event_invite,
      :email_on_event_post,
      :email_on_message,
      :email_on_mention,
      :email_on_tag

  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :token_authenticatable, :confirmable, :omniauthable

  has_many :authentications, dependent: :destroy
  has_one :profile, dependent: :destroy
  has_many :posts, dependent: :destroy
  has_many :events, dependent: :destroy
  has_many :event_invitations, dependent: :destroy
  has_many :invited_events, through: :event_invitations, source: :event
  has_many :attachments, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :likes, dependent: :destroy
  has_many :user_tags, dependent: :destroy

  has_many :conversation_users
  has_many :conversations, through: :conversation_users

  has_many :activities,
    class_name: 'PublicActivity::Activity', as: :owner
  has_and_belongs_to_many :newsfeed_activities,
      class_name: 'PublicActivity::Activity',
      join_table: :newsfeed_activities
  has_and_belongs_to_many :userfeed_activities,
      class_name: 'PublicActivity::Activity',
      join_table: :userfeed_activities
  has_many :notification_activities, dependent: :destroy
  has_many :notifications,
      class_name: 'PublicActivity::Activity',
      through: :notification_activities,
      source: :activity,
      select: 'activities.*,
               notification_activities.read AS read,
               notification_activities.clicked AS clicked'

  include Friendships

  validates_with UserValidator

  before_save :update_username_lower
  before_save :update_email_lower

  # Virtual attribute for authenticating by either username or email
  # This is in addition to a real persisted field like 'username'
  attr_accessor :login
  attr_accessor :skip_email_validation

  scope :confirmed, where{confirmed_at != nil}
  scope :admin, where(is_admin: true)

  delegate :first_name, :last_name, :full_name, to: :profile, prefix: false

  searchable do
    integer :id, :multiple => true
    text :username_lower, as: :username_lower_autosuggest, more_like_this: true
    text :email_lower, as: :email_lower_autosuggest, more_like_this: true
    time :confirmed_at

    text :first_name, as: :first_name_autosuggest do
      profile.first_name if profile
    end

    text :last_name, as: :last_name_autosuggest do
      profile.last_name if profile
    end

    text :about_me do
      profile.about_me if profile
    end

    text :location do
      profile.location if profile
    end

    text :education do
      profile.education if profile
    end

    text :occupation do
      profile.occupation if profile
    end
  end

  def self.simple_search(query, allowed_user_ids = [])
    self.search do
      fulltext query do
        boost_fields first_name: 2.0
      end

      if allowed_user_ids.any?
        with :id, allowed_user_ids
      end

      without :confirmed_at, nil
    end.results
  end

  #def self.search(query)
  #  if query.present?
  #    query = "%" + query.downcase + "%"
  #    confirmed.joins(:profile).where{(username_lower =~ query) | (email_lower =~ query) | (lower(profiles.first_name) =~ query) | (lower(profiles.last_name) =~ query) | (lower(profiles.about_me) =~ query) | (lower(profiles.location) =~ query) | (lower(profiles.education) =~ query) | (lower(profiles.occupation) =~ query)}
  #  end
  #end

  def self.with_content
    joins(:userfeed_activities).group('users.id')
  end

  def self.username_length
    3..40
  end

  def self.find_first_by_auth_conditions(warden_conditions)
    conditions = warden_conditions.dup
    if login = conditions.delete(:login)
      where(conditions).where([
        "username_lower = :value OR email_lower = :value",
        { value: login.downcase }]
      ).first
    else
      where(conditions).first
    end
  end

  def self.from_omniauth(auth)
    authentication = Authentication.where(provider: auth.provider, uid: auth.uid.to_s).first_or_initialize
    if authentication.user.blank?
      user = User.where('email = ?', auth["info"]["email"]).first

      if user.blank?
        signup = Signup.new
        signup.password = Devise.friendly_token[0,10]
        signup.name = auth.info.name
        signup.email = auth.info.email
        signup.username = auth.info.nickname ? auth.info.nickname : signup.generate_username

        if auth.provider == 'facebook'
          info = auth.extra.raw_info
          signup.gender = info.gender if info.gender
          signup.username = info.username if info.username
          if info.birthday
            signup.birthday = Date.strptime(info.birthday, "%m/%d/%Y")
          end
          signup.image_url = "http://graph.facebook.com/#{auth.uid}/picture?height=1200"
        end

        signup.skip_confirmation!
        signup.skip_email_validation! if auth.provider == "twitter"
        signup.save

        user = signup.user
      end

      authentication.token = auth.credentials.token
      authentication.token_secret = auth.credentials.secret
      authentication.user_id = user.id
      authentication.save
    end
    authentication.user
  end

  def self.username_available?(username)
    lower = username.downcase
    !User.exists?(username_lower: lower)
  end

  def self.email_available?(email)
    lower = email.downcase
    !User.exists?(email_lower: lower)
  end

  def profile_photo_count
    attachments.profile.count
  end

  def cover_photo_count
    attachments.cover.count
  end

  def general_photo_count
    attachments.general.count
  end

  def update_tracked_fields!(request)
    old_current, new_current = self.current_sign_in_at, Time.now.utc
    self.last_sign_in_at     = old_current || new_current
    self.current_sign_in_at  = new_current

    old_current, new_current = self.current_sign_in_ip, request.remote_ip
    self.last_sign_in_ip     = old_current || new_current
    self.current_sign_in_ip  = new_current

    self.sign_in_count ||= 0
    self.sign_in_count += 1

    save(:validate => false) or raise "Devise trackable could not save #{inspect}." \
      "Please make sure a model using trackable can be saved at sign in."
  end

  def path
    "/user/#{username}"
  end

  protected

    def update_username_lower
      self.username_lower = username.downcase
    end

    def update_email_lower
      self.email_lower = email.downcase
    end

end
