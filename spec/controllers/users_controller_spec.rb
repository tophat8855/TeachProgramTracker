require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:location) { FactoryGirl.create(:residency_location) }
  let(:location2) { FactoryGirl.create(:residency_location) }

  let(:admin) { FactoryGirl.create(:user,
    name: 'Admin',
    email: 'admin@email.com',
    residency_location_id: location.id,
    admin: true
  )}

  let(:trainer) { FactoryGirl.create(:user,
    name: 'Trainer',
    email: 'trainer@email.com',
    residency_location_id: location.id,
    trainer: true
  )}

  let(:resident)  { FactoryGirl.create(:user,
    name: 'User',
    email: 'user@email.com',
    residency_location_id: location.id,
  )}

  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#index' do
    context 'when user is admin' do
      before do
        sign_in admin
      end

      it 'lists the users' do
        get :index
        users = assigns(:users)

        expect(users).to include(resident, admin)
      end
    end

    context 'when the user is a trainer' do
      before do
        sign_in trainer
      end

      it 'lists the users for that trainer' do
        get :index
        users = assigns(:users)

        expect(users).to include(resident)
        expect(users).to_not include(admin)
      end
    end

    context 'when the user is not a trainer or admin' do
      before do
        sign_in resident
      end

      it 'redirects them to their current user page' do
        get :index
        expect(response).to redirect_to(user_path resident.id)
      end
    end
  end

  describe '#show' do #TODO: Expand out once we hear back from product what the permissions should look like
    context 'instance variable assignement' do
      before do
        sign_in admin
      end

      it 'uses the residency location and procedures of the user' do
        procedure = FactoryGirl.create(:procedure, resident_name: resident.name, user_id: resident.id)
        other_procedure = FactoryGirl.create(:procedure, resident_name: resident.name, user_id: trainer.id)

        get :show, params: { id: resident.id }
        user = assigns(:user)
        residency_location = assigns(:location)
        procedures = assigns(:procedures)

        expect(user).to eq(resident)
        expect(residency_location).to eq(location)
        expect(procedures).to include(procedure)
        expect(procedures).to_not include(other_procedure)
      end
    end

    context 'when the current_user is admin and does have access to the user' do
      before do
        sign_in admin
      end

      it 'redirects to root' do
        get :show, params: { id: resident.id }
        expect(response.status).to be(200)
      end
    end

    context 'when the current_user is resident without access to admin' do
      before do
        sign_in resident
      end

      it 'redirects to root' do
        get :show, params: { id: admin.id }
        expect(response).to redirect_to(root_path)
      end
    end

    context 'when the current_user is trainer without access to user' do
      before do
        sign_in trainer
      end

      it 'redirects to root' do
        get :show, params: { id: admin.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
