require 'spec_helper'

describe Api::V1::UsersController do

  describe 'GET #self' do
    before(:each) do
      @user = FactoryGirl.create :user
      api_authorization_header @user.auth_token
      get :self
    end

    it "returns the information about the owner of the access token" do
      user_response = json_response[:user]
      expect(user_response[:email]).to eql @user.email
    end

    it { should respond_with 200 }
  end

  describe "GET #show" do
    before(:each) do
      @user = FactoryGirl.create :user
      get :show, id: @user.id
    end

    it "returns the information about a reporter on a hash" do
      user_response = json_response[:user]
      expect(user_response[:email]).to eq @user.email
    end

    it { should respond_with 200 }
  end

  describe "POST #create" do

    context "when is successfully created" do
      before(:each) do
        # Valid attributes
        @user_attributes = FactoryGirl.attributes_for :user
        post :create, { user: @user_attributes }
      end

      it "renders the json representation for the user record just created" do
        user_response = json_response[:user]
        expect(user_response[:email]).to eql @user_attributes[:email]
      end

      it { should respond_with 201 }
    end

    context "when is not created" do
      before(:each) do
        # No email (invalid attributes)
        @invalid_user_attributes = { password: "12345678",
                                     password_confirmation: "12345678" }
        post :create, { user: @invalid_user_attributes }
      end

      it "renders an errors json" do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      it "renders the json errors on why the user could not be created" do
        user_response = json_response
        expect(user_response[:errors][:email]).to include "can't be blank"
      end

      it { should respond_with 422 }
    end
  end

  describe "PUT/PATCH #update" do
    context "when is successfully updated" do
      before(:each) do
        # Updating user email
        @user = FactoryGirl.create :user
        api_authorization_header @user.auth_token # Put user's auth token in the authentication header
        patch :update, { id: @user.id, user: { email: "newemail@example.com" } }
      end

      it "renders the json representation for the updated user" do
        user_response = json_response[:user]
        expect(user_response[:email]).to eql "newemail@example.com"
      end

      it { should respond_with 200 }
    end

    context "when is not created" do
      before(:each) do
        # Updating user email with invalid email format
        @user = FactoryGirl.create :user
        api_authorization_header @user.auth_token # Put user's auth token in the authentication header
        patch :update, { id: @user.id, user: { email: "invalidemail.org" } }
      end

      it "renders an errors json" do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      it "renders the json errors as to why the user could not be created" do
        user_response = json_response
        expect(user_response[:errors][:email]).to include "is invalid"
      end

      it { should respond_with 422 }
    end

  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      api_authorization_header @user.auth_token # Put user's auth token in the authentication header
      delete :destroy, id: @user.auth_token
    end

    it { should respond_with 204 }

  end


  describe "GET #search" do
    before(:each) do
      @user = FactoryGirl.create :user
      api_authorization_header @user.auth_token
      FactoryGirl.create :user, { username:  'xmichael_scott'}
      FactoryGirl.create :user, { full_name: 'Michael' }
      FactoryGirl.create :user, { username:  'boris_99' }
    end

    it "returns a list of users with username or full name like query param" do
      get :search, { query: 'michael' }
      expect(json_response[:users].count).to eql 2
    end

  end

end