# == Schema Information
#
# Table name: attachments
#
#  id               :integer          not null, primary key
#  filepicker_url   :string(255)
#  s3_key           :string(255)
#  filename         :string(255)
#  mimetype         :string(255)
#  filesize         :integer
#  media_type       :string(255)
#  user_id          :integer          indexed
#  attachable_id    :integer          indexed => [attachable_type]
#  attachable_type  :string(255)      indexed => [attachable_id]
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  width            :integer
#  height           :integer
#  sub_type         :string(255)      indexed
#  total_like_count :integer          default(0), not null
#  like_counts      :text
#  comments_count   :integer          default(0), not null
#

require 'rest_client'
require 'open-uri'
require 'fastimage'
require 'json'

class Attachment < ActiveRecord::Base

  belongs_to :user
  belongs_to :attachable, polymorphic: true
  has_many :comments, as: :commentable, dependent: :destroy
  has_many :commenters, class_name: 'User', through: :comments, source: :user, uniq: true
  has_many :likes, as: :likeable, dependent: :destroy

  serialize :like_counts

  attr_accessible :filepicker_url,
      :url,
      :s3_key,
      :filename,
      :mimetype,
      :filesize,
      :media_type,
      :width,
      :height,
      :sub_type

  validates_presence_of :filepicker_url
  validates_presence_of :user
  # validates_presence_of :attachable
  validate :attachable_belongs_to_user
  validate :sub_type_is_allowed

  after_save :update_attachable

  scope :general, where{(attachable_type != 'Profile') & ((sub_type == nil) | (sub_type.not_in ['event_photo', 'cover_photo', 'yostalgia_cover']))}
  scope :profile, where{(sub_type == nil) & (attachable_type == 'Profile')}
  scope :cover, where{(sub_type == 'cover_photo') & (attachable_type == 'Profile')}
  scope :yostalgia_cover, where{sub_type == 'yostalgia_cover'}

  scope :except_event, where{(sub_type == nil) | (sub_type.not_in ['event_photo', 'cover_photo'])}

  delegate :is_private?, to: :attachable

  def self.new_from_url(url, width = nil, height = nil)
    unless width && height
      width, height = FastImage.size(url)
    end

    fp_api_key = Rails.application.config.filepicker_rails.api_key
    fp_upload_url = "https://www.filepicker.io/api/store/S3?key=#{fp_api_key}"

    open_retries = 0
    begin
      file = open(url, allow_redirections: :all)
    rescue OpenURI::HTTPError
      open_retries += 1
      retry unless open_retries == 3
      raise
    end

    post_retries = 0
    begin
      response = RestClient.post fp_upload_url, fileUpload: file
    rescue RestClient::Exception
      post_retries += 1
      retry unless post_retries == 3
      raise
    end
    result = JSON.parse(response.to_s)

    attachment = Attachment.new

    attachment.url = result['url']
    attachment.s3_key = result['key']
    attachment.filename = result['filename']
    attachment.mimetype = result['type']
    attachment.filesize = result['size'].to_i
    attachment.width = width
    attachment.height = height

    return attachment
  end

  def url=(new_url)
    self.filepicker_url = new_url
  end

  def url
    if Rails.env.staging?
      filepicker_url.sub(/https/, 'http').sub(/www\.filepicker\.io/, 'assets.staging.yostalgia.com')
    elsif Rails.env.production?
      filepicker_url.sub(/https/, 'http').sub(/www\.filepicker\.io/, 'assets.yostalgia.com')
    else
      filepicker_url
    end
  end

  def path
    case attachable_type
    when 'Profile'
      "#{attachable.path}/profile_photos/#{id}"
    when 'Post'
      "#{attachable.path}/#{id}"
    end
  end

  private

    def attachable_belongs_to_user
      unless sub_type == 'yostalgia_cover'
        if attachable && user && attachable.user != user
          errors.add(:attachable, 'must be one of your own items')
        end
      end
    end

    def update_attachable
      if attachable.is_a?(Profile)
        attachable.update_photos(self)
      end
    end

    def sub_type_is_allowed
      if sub_type == 'yostalgia_cover' && !user.try(:is_admin)
        errors.add(:sub_type, 'can only be set by admins')
      end
    end

end
