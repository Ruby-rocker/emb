class ProfileVersionSerializer < ApplicationSerializer

  attributes :id,
      :first_name,
      :last_name,
      :gender,
      :about_me,
      :location,
      :education,
      :occupation,
      :date_of_birth,
      :errors,
      :timestamp,
      :profile_id

  def id
    if object.version
      object.version.id
    else
      object.versions.last.id
    end
  end

  def profile_id
    object.id
  end

  has_one :user, include: false
  has_one :photo, class_name: 'Attachment'
  has_one :cover_photo, class_name: 'Attachment', embed: :ids, include: true, root: 'attachments'

end
