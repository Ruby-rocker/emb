require 'spec_helper'

describe Api::V1::ProfilesController do
  let(:user)    { Fabricate(:user) }
  let(:profile) { user.profile }

  # describe "GET index" do
  #   before { get :index }

  #   it "returns http 200" do
  #     response.response_code.should == 200
  #   end
  # end

  describe "GET show" do
    context "unauthorized" do
      before { get :show, id: profile.id }

      it "returns http 200" do
        expect(response.response_code).to  eq(200)
      end
    end

    context "authorized" do
      before do
        user.confirm!
        user.ensure_authentication_token!
        get :show, id: profile.id, auth_token: user.authentication_token
      end
      subject { JSON.parse response.body }

      it "wraps around profile" do should include 'profile' end
      context "inside profile" do
        subject { (JSON.parse response.body)['profile'] }

        it "includes id" do should include 'id' end
        it "includes first_name" do should include 'first_name' end
        it "includes last_name" do should include 'last_name' end
        it "includes gender" do should include 'gender' end
        it "includes about_me" do should include 'about_me' end
        it "includes location" do should include 'location' end
        it "includes education" do should include 'education' end
        it "includes occupation" do should include 'occupation' end
        it "includes date_of_birth" do should include 'date_of_birth' end
      end

      it "returns http 200" do
        expect(response.response_code).to eq(200)
      end
    end
  end

  describe "PUT update" do
    context "when unauthorized" do
      before { put :update, id: profile.id, profile: { about_me: 'Test' } }

      it "returns http 401" do
        expect(response.response_code).to eq(401)
      end
    end

    context "when editing another user's profile" do
      before do
        new_profile = Fabricate(:profile)
        user.confirm!
        user.ensure_authentication_token!
        put :update,
                id: new_profile.id,
                profile: { about_me: 'Test' },
                auth_token: user.authentication_token
      end

      it "should return http 401" do
        expect(response.response_code).to eq(401)
      end
    end

    context "when editing own profile" do
      before do
        user.confirm!
        user.ensure_authentication_token!
        put :update,
                id: user.profile.id,
                profile: {
                  user_id: user.id,
                  about_me: 'New about me.'
                },
                auth_token: user.authentication_token
      end

      it "should ignore 'user_id'" do
        expect(response).to be_success
      end

      it "should return http 200" do
        expect(response.response_code).to eq(200)
      end

      it "should update profile" do
        expect(profile.reload.about_me).to eq('New about me.')
      end

      it "should wrap profile" do
        expect(JSON.parse(response.body)).to include('profile')
      end
    end
  end
end
