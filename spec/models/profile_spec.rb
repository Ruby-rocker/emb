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

require 'spec_helper'

describe Profile do
  it { should have_db_column :user_id }
end
