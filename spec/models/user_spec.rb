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

require 'spec_helper'

describe User do

  it { should have_one :profile }

  %w(username email password remember_me).each do |attr|
    it { should allow_mass_assignment_of attr }
  end

  context "validations" do
    it { should validate_presence_of :email }
    it { should validate_presence_of :username }
    it { should allow_value('test_user123').for(:username) }
    it { should_not allow_value('test-user123').for(:username).
                  with_message('must include only letters and numbers') }
    it { should_not allow_value('_test_user123').for(:username).
                  with_message('must begin with a letter or number') }
    it { should ensure_length_of(:username).
                  is_at_least(3).
                  is_at_most(20).
                  with_short_message('must be longer than 3 characters').
                  with_long_message('must be shorter than 20 characters') }

    context "with db" do
      before(:each) { Fabricate(:user) }

      it { should validate_uniqueness_of(:email).case_insensitive }
      it { should validate_uniqueness_of(:username).
                    case_insensitive.
                    with_message('already taken') }
    end
  end

  describe "#save callbacks" do
    before do
      @user = User.new(username: 'Test', password: 'testing', email: 'Test@Example.com')
      @user.save
    end

    it "should set username_lower on save" do
      expect(@user.username_lower).to eq('test')
    end

    it "should set email_lower on save" do
      expect(@user.email_lower).to eq('test@example.com')
    end
  end

  describe ".find_first_by_auth_conditions" do
    context "with login" do
      let(:user) { Fabricate(:user) }
      before { user }

      it "should find user by username" do
        expect(User.find_first_by_auth_conditions(login: user.username)).to eq(user)
      end

      it "should find user by email" do
        expect(User.find_first_by_auth_conditions(email: user.email)).to eq(user)
      end
    end
  end

  describe ".username_available?" do
    let(:user) { Fabricate(:user) }
    before { user }

    it "returns true for available username" do
      expect(User.username_available?('new_username')).to be_true
    end

    it "returns false for unavailable username" do
      expect(User.username_available?(user.username.upcase)).to be_false
    end
  end

  describe ".email_available?" do
    let(:user) { Fabricate(:user) }
    before { user }

    it "returns true for available email" do
      expect(User.email_available?('new_email@example.com')).to be_true
    end

    it "returns false for unavailable email" do
      expect(User.email_available?(user.email.upcase)).to be_false
    end
  end

end
