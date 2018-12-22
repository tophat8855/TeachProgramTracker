require 'rails_helper'

RSpec.describe UsersController, type: :controller do
  include Devise::Test::ControllerHelpers

  let(:location) { FactoryBot.create(:residency_location) }
  let(:location2) { FactoryBot.create(:residency_location) }

  let(:admin) { FactoryBot.create(:user,
    name: 'Admin',
    email: 'admin@email.com',
    residency_location_id: location.id,
    admin: true
  )}

  let(:trainer) { FactoryBot.create(:user,
    name: 'Trainer',
    email: 'trainer@email.com',
    residency_location_id: location.id,
    trainer: true
  )}

  let(:resident)  { FactoryBot.create(:user,
    name: 'Resident',
    email: 'resident@email.com',
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

  describe '#show' do
    context 'instance variable assignment' do
      before do
        sign_in admin
      end

      it 'uses the residency location and procedures of the user' do
        procedure = FactoryBot.create(:procedure, resident_name: resident.name, user_id: resident.id)
        other_procedure = FactoryBot.create(:procedure, resident_name: resident.name, user_id: trainer.id)

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

    context 'when the current_user is admin' do
      let(:admin_to_view) { FactoryBot.create(:user,
        name: 'Admin To View',
        email: 'admin_to_view@email.com',
        residency_location_id: location.id,
        admin: true
      )}

      before do
        sign_in admin
      end

      it 'can view self' do
        get :show, params: { id: admin.id }
        expect(response.status).to be(200)
      end

      it 'can view other admins' do
        get :show, params: { id: admin_to_view.id }
        expect(response.status).to be(200)
      end

      it 'can view trainers' do
        get :show, params: { id: trainer.id }
        expect(response.status).to be(200)
      end

      it 'can view residents' do
        get :show, params: { id: trainer.id }
        expect(response.status).to be(200)
      end
    end

    context 'when the current_user is trainer' do
      let(:trainer_to_view) { FactoryBot.create(:user,
        name: 'Trainer To View',
        email: 'trainer_to_view@email.com',
        residency_location_id: location.id,
        trainer: true
      )}

      before do
        sign_in trainer
      end

      it 'can view self' do
        get :show, params: { id: trainer.id }
        expect(response.status).to be(200)
      end

      it 'cannot view admins' do
        get :show, params: { id: admin.id }
        expect(response).to redirect_to(root_path)
      end

      it 'cannot view other trainers' do
        get :show, params: { id: trainer_to_view.id }
        expect(response).to redirect_to(root_path)
      end

      it 'can view residents' do
        get :show, params: { id: resident.id }
        expect(response.status).to be(200)
      end
    end

    context 'when the current_user is resident' do
      let(:resident_to_view)  { FactoryBot.create(:user,
        name: 'Resident to View',
        email: 'resident_to_view@email.com',
        residency_location_id: location.id,
      )}

      before do
        sign_in resident
      end

      it 'can view self' do
        get :show, params: { id: resident.id }
        expect(response.status).to be(200)
      end

      it 'cannot view admins' do
        get :show, params: { id: admin.id }
        expect(response).to redirect_to(root_path)
      end

      it 'cannot view trainers' do
        get :show, params: { id: trainer.id }
        expect(response).to redirect_to(root_path)
      end

      it 'cannot view other residents' do
        get :show, params: { id: resident_to_view.id }
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe '#invite' do
    before do
      sign_in admin
    end

    context 'when creating a user with a unique email' do
      it 'should create the user' do
        post :invite, params: { user: {
          email: Faker::Internet.email,
          name: 'Name',
          residency_location_id: location.id,
          status: 'R2',
          trainer: false,
          admin: false
          }
        }
        expect(response).to redirect_to(users_path)
      end
    end

    context 'when creating a user with duplicate email' do
      it 'should not send invite or create user' do
        post :invite, params: { id: resident.id, user: {
          email: resident.email,
          name: 'Name',
          residency_location_id: location.id,
          status: 'R2',
          trainer: false,
          admin: false
          }
        }
        expect(response).to redirect_to(new_user_path)
        expect(flash[:error][:email]).to eq(['has already been taken'])
      end
    end
  end

  describe '#update' do
    before do
      sign_in admin
    end

    context 'when updating an email with a unique email' do
      it 'should update the email of the user' do
        patch :update, params: { id: resident.id, user: { email: 'unique_email@email.com' } }
        expect(response).to redirect_to(users_path)
      end
    end

    context 'when updating an email to another email in the system' do
      it 'should not update email, should stay on edit page' do
        patch :update, params: { id: resident.id, user: { email: trainer.email } }
        expect(response).to redirect_to(edit_user_path(resident.id))
        expect(flash[:error]).to eq({email: ['has already been taken']})

        unchanged_user = User.find(resident.id)
        expect(unchanged_user.email).to eq('resident@email.com')
        expect(unchanged_user.name).to eq('Resident')
        expect(unchanged_user.residency_location_id).to eq(location.id)
      end
    end
  end
end
