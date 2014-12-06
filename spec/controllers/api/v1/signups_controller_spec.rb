require 'spec_helper'

describe Api::V1::SignupsController do
  describe "POST create" do
    context "missing params" do
      it "returns http 400" do
        post :create
        expect(response.response_code).to eq(400)
      end
    end

    let(:params) do
      {
        email: 'test@example.com',
        username: 'validuser',
        password: 'password',
        first_name: 'First',
        last_name: 'Last'
      }
    end

    context "valid signup" do
      before { post :create, signup: params }

      it "returns http 201" do
        expect(response.response_code).to eq(201)
      end

      it "includes signup" do
        expect(JSON.parse(response.body)).to include('signup')
      end
    end

    context "invalid signup" do
      before { post :create, signup: params.merge(username: '_invalid') }

      it "returns http 422" do
        expect(response.response_code).to eq(422)
      end

      context "response" do
        subject { JSON.parse response.body }
        it "includes signup" do should include 'signup' end
        it "includes errors" do subject['signup'].should include 'errors' end
      end
    end
  end

  describe "GET check_email" do
    context "available email" do
      before { get :check_email, email: 'available@example.com' }

      it "returns http 200" do
        expect(response.response_code).to eq(200)
      end

      context "response" do
        subject { JSON.parse response.body }

        it "includes available" do should include 'available' end
        it "availability is true" do subject['available'].should be_true end
      end
    end

    context "taken email" do
      before do
        user = Fabricate(:user)
        get :check_email, email: user.email
      end

      it "returns http 200" do
        expect(response.response_code).to eq(200)
      end

      context "response" do
        subject { JSON.parse response.body }

        it "includes available" do should include 'available' end
        it "availability is false" do subject['available'].should be_false end
      end
    end

    context "missing params" do
      it "returns http 400" do
        get :check_email
        expect(response.response_code).to eq(400)
      end
    end
  end

  describe "GET check_username" do
    context "available username" do
      before { get :check_username, username: 'available'}

      it "returns http 200" do
        expect(response.response_code).to eq(200)
      end

      context "response" do
        subject { JSON.parse response.body }
        it "includes available" do should include 'available' end
        it "availability is true" do subject['available'].should be_true end
      end
    end

    context "unavailable username" do
      before do
        user = Fabricate(:user)
        get :check_username, username: user.username
      end

      it "returns http 200" do
        expect(response.response_code).to eq(200)
      end

      context "response" do
        subject { JSON.parse response.body }
        it "includes available" do should include 'available' end
        it "availability is false" do
          expect(subject['available']).to be_false
        end
      end
    end

    context "invalid username" do
      before { get :check_username, username: '_invalid' }

      it "returns http 200" do
        expect(response.response_code).to eq(200)
      end

      it "includes errors" do
        expect(JSON.parse(response.body)).to include('errors')
      end
    end

    context "missing params" do
      it "returns http 400" do
        get :check_username
        expect(response.response_code).to eq(400)
      end
    end
  end
end
