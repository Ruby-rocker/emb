require 'spec_helper'

describe Api::V1::UsersController do
  let(:user) { Fabricate(:user) }
  before { user } # initialize it

  describe "GET show" do
    context "unauthorized" do
      before do |variable|
        user.confirm! # only confirmed users are accessible
        get :show, id: user.id
      end
      subject { JSON.parse response.body }

      it "wraps around user" do should include 'user' end
      context "inside user" do
        subject { (JSON.parse response.body)['user'] }

        it "includes id" do should include 'id' end
        it "includes username" do should include 'username' end
        it "includes profile_id" do should include 'profile_id' end
        it "does not include email" do should_not include 'email' end
      end

      it "sideloads profiles" do should include 'profiles' end

      it "returns http 200" do
        expect(response.response_code).to eq(200)
      end
    end

    context "authorized retrieving current user" do
      before do
        user.ensure_authentication_token!
        user.confirm!
        get :show, id: user.id, auth_token: user.authentication_token
      end
      subject { JSON.parse response.body }

      it "wraps around user" do should include 'user' end
      context "inside user" do
        subject { (JSON.parse response.body)['user'] }

        it "includes id" do should include 'id' end
        it "includes username" do should include 'username' end
        it "includes profile_id" do should include 'profile_id' end
        it "includes email" do should include 'email' end
      end

      it "returns http 200" do
        expect(response.response_code).to eq(200)
      end
    end

    context "authorized retrieving other user" do
      before do
        other_user = Fabricate(:user)
        other_user.confirm!

        user.confirm!
        user.ensure_authentication_token!
        get :show, id: other_user.id, auth_token: user.authentication_token
      end
      subject { JSON.parse response.body }

      it "wraps around user" do should include 'user' end
      context "inside user" do
        subject { (JSON.parse response.body)['user'] }

        it "includes id" do should include 'id' end
        it "includes username" do should include 'username' end
        it "includes profile_id" do should include 'profile_id' end
        it "does not include email" do should_not include 'email' end
      end

      it "returns http 200" do
        expect(response.response_code).to eq(200)
      end
    end
  end

end
