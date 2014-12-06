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

Fabricator(:user) do
  username        { sequence(:username) { |i| "user#{i}"} }
  username_lower  { |attrs| attrs[:username].downcase}
  email           { sequence(:email) { |i| "user#{i}@example.com"} }
  email_lower     { |attrs| attrs[:email].downcase }
  password        'foobarbaz'
  profile
end
