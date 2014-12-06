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

Fabricator(:profile) do

  first_name    'Foo'
  last_name     'Bar'
  gender        'Male'
  about_me      'This is a dummy about me text.'
  location      'Test Land'
  education     'Some'
  occupation    'Tester'
  date_of_birth { Date.parse '24/02/2013' }

end
