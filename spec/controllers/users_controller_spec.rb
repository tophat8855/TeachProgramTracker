require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:location) { FactoryGirl.create(:residency_location) }

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
end
