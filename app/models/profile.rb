# == Schema Information
#
# Table name: profiles
#
#  id             :integer          not null, primary key
#  user_id        :integer          indexed
#  first_name     :string(255)
#  last_name      :string(255)
#  gender         :string(255)
#  about_me       :text
#  location       :string(255)
#  education      :string(255)
#  occupation     :string(255)
#  date_of_birth  :date
#  avatar_url     :string(255)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  photo_id       :integer
#  cover_photo_id :integer
#

class Profile < ActiveRecord::Base
  has_paper_trail class_name: 'ProfileVersion'

  belongs_to :user
  has_many :photos, class_name: 'Attachment', as: :attachable,
    conditions: { sub_type: nil }

  has_many :cover_photos, class_name: 'Attachment', as: :attachable,
    conditions: { sub_type: 'cover_photo' }

  attr_accessor :timestamp

  attr_accessible :first_name,
      :last_name,
      :gender,
      :about_me,
      :location,
      :education,
      :occupation,
      :date_of_birth,
      :cover_photo_id

  validates :first_name, :last_name, presence: true

  after_create :set_default_cover_photo

  scope :latest, -> { order('created_at DESC').limit(1) }

  def is_private?
    false
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def photo
    Attachment.find(photo_id) if photo_id
  end

  def cover_photo
    Attachment.find(cover_photo_id) if cover_photo_id
  end

  def update_photos(attachment)
    if !attachment.sub_type || attachment.sub_type == ''
      self.photo_id = attachment.id
    elsif attachment.sub_type == 'cover_photo'
      self.cover_photo_id = attachment.id
    end
    self.save
  end

  def path
    "/user/#{user.username}"
  end

  def version_for_date(date)
    timestamp = date.end_of_day
    profile_version = self.version_at(timestamp)
    profile_version ||= self.version_at(self.created_at.end_of_day)
    profile_version.timestamp = timestamp.beginning_of_day
    profile_version
  end

  private

    def set_default_cover_photo
      if cover_photo_id == nil && Attachment.yostalgia_cover.count > 0
        attachment_id = Attachment.yostalgia_cover.order("RANDOM()").first.id
        self.update_attribute :cover_photo_id, attachment_id
      end
    end

end
