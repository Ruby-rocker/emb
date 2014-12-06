require 'spec_helper'

describe SessionsController do
  let(:user) { Fabricate(:user) }

  before do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  context 'JSON' do
    describe 'POST create' do
      context 'no param' do
        before { post :create, format: :json }
        it_behaves_like 'http code', 400
      end

      context 'missing param' do
        before { post :create, format: :json, login: user.email, password: '' }
        it_behaves_like 'http code', 400
      end

      context 'wrong credentials' do
        before { post :create, format: :json, login: user.email, password: 'wrong' }
        it_behaves_like 'http code', 401
      end

      context "with unconfirmed user" do
        before do
          post :create, format: :json, login: user.username, password: user.password
        end
        subject { JSON.parse response.body }

        it_behaves_like 'http code', 401

        it "should contain 'error'" do should include 'error' end
        it "error has message" do
          expect(subject['error']).to eq('confirmation required')
        end
      end

      context "with confirmed user" do
        before do
          user.confirm!
          user.ensure_authentication_token!
        end

        context 'normal email + password auth' do
          it_behaves_like 'auth response' do
            let(:params) { { login: user.email, password: user.password } }
          end
        end

        context "normal username + password auth" do
          it_behaves_like 'auth response' do
            let(:params) { { login: user.username, password: user.password } }
          end
        end

        context 'remember token auth' do
          it_behaves_like 'auth response' do
            let(:params) do
              user.remember_me!
              data = User.serialize_into_cookie(user)
              token = "#{data.first.first}-#{data.last}"
              { remember_token: token }
            end
          end
        end

        context "auth token auth" do
          it_behaves_like 'auth response' do
            let(:params) { { auth_token: user.authentication_token } }
          end
        end
      end
    end

    describe 'DELETE destroy' do
      before do
        user.confirm!
        user.ensure_authentication_token!
      end

      context 'no param' do
        before { delete :destroy, format: :json }
        it_behaves_like 'http code', 400
      end

      context 'wrong credentials' do
        before { delete :destroy, format: :json, auth_token: '' }
        it_behaves_like 'http code', 401
      end

      context 'normal auth token param' do
        before { delete :destroy, format: :json, auth_token: user.authentication_token }

        it 'includes user id' do
          expect(JSON.parse(response.body)).to include('user_id')
        end

        it_behaves_like 'http code', 200
      end
    end
  end

end
