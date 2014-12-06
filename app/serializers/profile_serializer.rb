class ProfileSerializer < ApplicationSerializer

  attributes :id,
      :first_name,
      :last_name,
      :gender,
      :about_me,
      :location,
      :education,
      :occupation,
      :date_of_birth,
      :errors

  has_one :user
  has_one :photo, class_name: 'Attachment', embed: :ids, include: true
  has_one :cover_photo, class_name: 'Attachment', embed: :ids, include: true

end
