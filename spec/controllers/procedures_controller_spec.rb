require 'rails_helper'

RSpec.describe ProceduresController, type: :controller do
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

  let(:resident) { FactoryGirl.create(:user,
    name: 'Resident',
    email: 'resident@email.com',
    residency_location_id: location.id,
  )}

  let(:procedure1) { FactoryGirl.create(:procedure,
    resident_name: resident.name,
    user_id: resident.id
  )}

  let(:procedure2) { FactoryGirl.create(:procedure,
    resident_name: trainer.name,
    user_id: trainer.id
  )}

  before :each do
    @request.env['devise.mapping'] = Devise.mappings[:user]
  end

  describe '#index' do
    context 'when user is admin' do
      it 'assigns correct instance variables' do
        sign_in admin
        get :index

        procedures = assigns(:procedures)
        expect(procedures).to include(procedure1, procedure2)

        priviledged = assigns(:priviledged)
        expect(priviledged).to be true
      end
    end

    context 'when user is trainer' do
      it 'assigns correct instance variables' do
        sign_in trainer
        get :index

        procedures = assigns(:procedures)
        expect(procedures).to include(procedure1, procedure2)

        priviledged = assigns(:priviledged)
        expect(priviledged).to be true
      end
    end

    context 'when user is resident' do
      it 'assigns correct instance variables' do
        sign_in resident
        get :index

        procedures = assigns(:procedures)
        expect(procedures).to include(procedure1)
        expect(procedures).not_to include(procedure2)

        priviledged = assigns(:priviledged)
        expect(priviledged).to be false
      end
    end
  end

  describe '#show' do
    let(:procedure) { FactoryGirl.create(:procedure,
      resident_name: resident.name,
      user_id: resident.id,
      trainer_id: trainer.id,
      trainer_name: trainer.name
      )
    }

    it 'assigns correct instance variables' do
      sign_in resident
      get :show, params: {id: procedure.id}

      procedure = assigns(:procedure)
      expect(procedure).to eq procedure

      trainer_name = assigns(:trainer_name)
      expect(trainer_name).to eq trainer.name
    end

    context 'if trainer is not in the db as a user' do
      let(:procedure_with_custom_trainer) { FactoryGirl.create(:procedure,
        resident_name: resident.name,
        user_id: resident.id,
        trainer_id: -1,
        trainer_name: 'Custom Trainer Name'
        )
      }

      it 'assigns the trainer name correctly still' do
        sign_in resident
        get :show, params: {id: procedure_with_custom_trainer.id}

        trainer_name = assigns(:trainer_name)
        expect(trainer_name).to eq 'Custom Trainer Name'
      end
    end
  end

  describe '#new' do
    context 'when user is admin' do
      it 'assigns correct instance variables' do
        sign_in admin
        get :new

        name_entry = assigns(:allowNameEntry)
        expect(name_entry).to be true

        default_resident_name = assigns(:residentName)
        expect(default_resident_name).to eq ''
      end
    end

    context 'when user is trainer' do
      it 'assigns correct instance variables' do
        sign_in trainer
        get :new

        name_entry = assigns(:allowNameEntry)
        expect(name_entry).to be true

        default_resident_name = assigns(:residentName)
        expect(default_resident_name).to eq ''
      end
    end

    context 'when user is resident' do
      it 'assigns correct instance variables' do
        sign_in resident
        get :new

        name_entry = assigns(:allowNameEntry)
        expect(name_entry).to be false

        default_resident_name = assigns(:residentName)
        expect(default_resident_name).to eq resident.name
      end
    end
  end

  describe '#create' do
    context 'when user is resident' do
      before :each do
        sign_in resident
      end

      it 'creates a new procedure' do
        post :create, params: { procedure: {
          resident_name: resident.name,
          name: 'Ultrasound',
          date: Date.today,
          assistance: 'Observed',
          notes: 'procedure notes',
          gestation: '12',
          resident_status: resident.status,
          user_id: resident.id,
          trainer_id: trainer.id,
          trainer_name: trainer.name,
          clinic_location: location,
        },
        'New Clinic Location': nil,
        'New Trainer': nil
        }

        expect(response.status).to eq(302)
        expect(response).to redirect_to(procedures_path)

        all_procedures = Procedure.all
        expect(all_procedures.count).to be 1

        new_procedure = all_procedures.first
        expect(new_procedure.resident_name).to eq resident.name
        expect(new_procedure.name).to eq 'Ultrasound'
        expect(new_procedure.date).to eq Date.today
        expect(new_procedure.assistance).to eq 'Observed'
        expect(new_procedure.notes).to eq 'procedure notes'
        expect(new_procedure.gestation).to eq 12
        expect(new_procedure.resident_status).to eq resident.status
        expect(new_procedure.trainer_id).to eq trainer.id
        expect(new_procedure.trainer_name).to eq trainer.name
        expect(new_procedure.clinic_location).to eq location.id.to_s
      end

      context 'when user adds new clinic location' do
        it 'creates a new procedure with the custom location' do
          post :create, params: { procedure: {
            resident_name: resident.name,
            name: 'Ultrasound',
            date: Date.today,
            assistance: 'Observed',
            notes: 'procedure notes',
            gestation: '12',
            resident_status: resident.status,
            user_id: resident.id,
            trainer_id: trainer.id,
            trainer_name: trainer.name
          },
          'New Clinic Location': 'Mars',
          'New Trainer': nil
          }

          expect(response.status).to eq(302)
          expect(response).to redirect_to(procedures_path)

          all_procedures = Procedure.all
          expect(all_procedures.count).to be 1

          new_procedure = all_procedures.first
          expect(new_procedure.resident_name).to eq resident.name
          expect(new_procedure.name).to eq 'Ultrasound'
          expect(new_procedure.date).to eq Date.today
          expect(new_procedure.assistance).to eq 'Observed'
          expect(new_procedure.notes).to eq 'procedure notes'
          expect(new_procedure.gestation).to eq 12
          expect(new_procedure.resident_status).to eq resident.status
          expect(new_procedure.trainer_id).to eq trainer.id
          expect(new_procedure.trainer_name).to eq trainer.name
          expect(new_procedure.clinic_location).to eq 'Mars'
        end
      end

      context 'when user adds new trainer' do
        it 'creates a new procedure with the custom trainer' do
          post :create, params: { procedure: {
            resident_name: resident.name,
            name: 'Ultrasound',
            date: Date.today,
            assistance: 'Observed',
            notes: 'procedure notes',
            gestation: '12',
            resident_status: resident.status,
            user_id: resident.id,
          },
          'New Clinic Location': nil,
          'New Trainer': 'Ms. Frizzle'
          }

          expect(response.status).to eq(302)
          expect(response).to redirect_to(procedures_path)

          all_procedures = Procedure.all
          expect(all_procedures.count).to be 1

          new_procedure = all_procedures.first
          expect(new_procedure.resident_name).to eq resident.name
          expect(new_procedure.name).to eq 'Ultrasound'
          expect(new_procedure.date).to eq Date.today
          expect(new_procedure.assistance).to eq 'Observed'
          expect(new_procedure.notes).to eq 'procedure notes'
          expect(new_procedure.gestation).to eq 12
          expect(new_procedure.resident_status).to eq resident.status
          expect(new_procedure.trainer_id).to eq nil
          expect(new_procedure.trainer_name).to eq 'Ms. Frizzle'
        end
      end
    end

    context 'when user is trainer' do
      #TODO: More tests here
    end

    context 'when user is admin' do
      #TODO: More tests here
    end
  end

  describe '#edit' do
    let(:procedure) { FactoryGirl.create(:procedure,
      resident_name: resident.name,
      user_id: resident.id,
      trainer_id: trainer.id,
      trainer_name: trainer.name
      )
    }

    context 'when user is admin' do
      it 'assigns correct instance variables' do
        sign_in admin
        get :edit, params: {id: procedure.id}

        name_entry = assigns(:allowNameEntry)
        expect(name_entry).to be true

        default_resident_name = assigns(:residentName)
        expect(default_resident_name).to eq ''

        trainers = assigns(:trainers)
        expect(trainers).to include(trainer.name)

        #TODO: Assignment for @clinic_locations
        #TODO: Assignment for @trainers
      end
    end

    context 'when user is trainer' do
      it 'assigns correct instance variables' do
        sign_in trainer
        get :edit, params: {id: procedure.id}

        name_entry = assigns(:allowNameEntry)
        expect(name_entry).to be true

        default_resident_name = assigns(:residentName)
        expect(default_resident_name).to eq ''
      end
    end

    context 'when user is resdient' do
      it 'assigns correct instance variables' do
        sign_in resident
        get :edit, params: {id: procedure.id}

        name_entry = assigns(:allowNameEntry)
        expect(name_entry).to be false

        default_resident_name = assigns(:residentName)
        expect(default_resident_name).to eq resident.name
      end
    end
  end

  describe '#update' do
    context 'when user is resident' do
      let(:updated_location) { FactoryGirl.create(:residency_location) }

      let(:procedure) { FactoryGirl.create(:procedure,
        resident_name: resident.name,
        user_id: resident.id,
        trainer_id: trainer.id,
        trainer_name: trainer.name
        )
      }

      before :each do
        sign_in resident
      end

      it 'updates the procedure' do
        patch :update, params: {
          id: procedure.id,
          procedure: {
            resident_name: resident.name,
            name: 'Ultrasound',
            date: Date.today,
            assistance: 'Performed',
            notes: 'Updated notes',
            gestation: 9,
            resident_status: resident.status,
            user_id: resident.id,
            clinic_location: updated_location.name,
            trainer_id: trainer.id,
            trainer_name: trainer.name
          },
          'New Clinic Location': nil,
          'New Trainer': nil
        }

        expect(response.status).to eq(302)
        expect(response).to redirect_to(procedures_path)

        updated_procedure = Procedure.find(procedure.id)
        expect(updated_procedure.resident_name).to eq resident.name
        expect(updated_procedure.name).to eq 'Ultrasound'
        expect(updated_procedure.date).to eq Date.today
        expect(updated_procedure.assistance).to eq 'Performed'
        expect(updated_procedure.notes).to eq 'Updated notes'
        expect(updated_procedure.gestation).to eq 9
        expect(updated_procedure.resident_status).to eq resident.status
        expect(updated_procedure.user_id).to eq resident.id
        expect(updated_procedure.trainer_id).to eq trainer.id
        expect(updated_procedure.trainer_name).to eq trainer.name
        expect(updated_procedure.clinic_location).to eq updated_location.name
      end
    end

    context 'when user is trainer' do
      #TODO: More Tests here.
    end

    context 'when user is admin' do
      #TODO: More Tests here.
    end
  end

  describe '#destroy' do
    let(:procedure) { FactoryGirl.create(:procedure,
      resident_name: resident.name,
      user_id: resident.id,
      trainer_id: trainer.id,
      trainer_name: trainer.name
      )
    }

    before do
      sign_in resident
    end

    it 'deletes the procedure' do
      delete :destroy, params: { id: procedure.id }

      expect(response.status).to eq(302)
      expect(response).to redirect_to(procedures_path)
    end
  end
end
