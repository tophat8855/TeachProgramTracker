require 'rails_helper'

RSpec.describe 'Procedure Features', type: :feature do
  let!(:location) { FactoryGirl.create(:residency_location) }
  let!(:resident) { FactoryGirl.create(:user,
    name: 'Resident Name',
    email: 'resident@email.com',
    residency_location_id: location.id,
    status: 'R2',
    password: 'password',
    password_confirmation: 'password')
  }

  let!(:trainer) { FactoryGirl.create(:user,
    name: 'Trainer Name',
    email: 'trainer@email.com',
    residency_location_id: location.id,
    trainer: true,
    password: 'password',
    password_confirmation: 'password')
  }

  let!(:procedure_1) { FactoryGirl.create(:procedure,
    resident_name: resident.name,
    resident_status: resident.status,
    user_id: resident.id,
    clinic_location: location.name,
    trainer_id: trainer.id)
  }

  let!(:procedure_2) { FactoryGirl.create(:procedure,
    resident_name: resident.name,
    resident_status: resident.status,
    name: 'MVA',
    user_id: resident.id,
    clinic_location: location.name)
  }

  before do
    login_resident

    click_on 'Procedures'
  end

  describe 'list of procedures' do
    it 'shows all the procedures for the current user' do
      expect(page).to have_content procedure_1.name
      expect(page).to have_content procedure_1.date.to_s
      expect(page).to have_content procedure_1.clinic_location
      expect(page).to have_content procedure_1.notes

      expect(page).to have_content procedure_2.name
      expect(page).to have_content procedure_2.notes
    end
  end

  describe 'show procedure details' do
    it 'shows the details of a procedure' do
      page.all('td.right.collapsing')[1].click_link('View')

      expect(page).to have_content procedure_1.name
      expect(page).to have_content procedure_1.date.to_s
      expect(page).to have_content procedure_1.clinic_location
      expect(page).to have_content procedure_1.notes
      expect(page).to have_content procedure_1.gestation
      expect(page).to have_content procedure_1.assistance
      expect(page).to have_content trainer.name
      expect(page).to have_content location.name
    end
  end

  describe 'create procedure' do
    it 'creates a procedure with desired details' do
      click_link 'Record New Procedure'

      fill_in 'Date', with: '2017-07-01'
      select 'IUD', from: 'Procedure Name'
      fill_in 'Gestation', with: 8
      select 'Observed', from: 'Assistance'
      select trainer.name, from: 'Trainer'
      select location.name, from: 'Clinic Location'
      fill_in 'Notes', with: 'asdfasdf'

      click_on 'Submit'

      expect(page).to have_content 'asdf'
    end

    context 'with a custom location' do
      it 'creates a procedure' do
        click_link 'Record New Procedure'

        fill_in 'Date', with: '2017-07-01'
        select 'IUD', from: 'Procedure Name'
        fill_in 'Gestation', with: 8
        select 'Observed', from: 'Assistance'
        select trainer.name, from: 'Trainer'
        fill_in 'New Clinic Location', with: 'Mars'
        fill_in 'Notes', with: 'asdfasdf'

        click_on 'Submit'

        expect(page).to have_content 'Mars'
      end
    end
  end

  describe 'update procedure' do
    it 'updates a procedure with desired details' do
      page.all('td.right.collapsing')[1].click_link('Edit')

      fill_in 'Date', with: '2017-07-01'
      select 'Contraceptive', from: 'Procedure Name'
      fill_in 'Gestation', with: 12
      select 'Performed', from: 'Assistance'
      select trainer.name, from: 'Trainer'
      select location.name, from: 'Clinic Location'
      fill_in 'Notes', with: 'jkl;jkl;'

      click_on 'Submit'

      expect(page).to have_content 'jkl;jkl;'
      expect(page).to have_content 'Contraceptive'
    end

    context 'with a custom location' do
      it 'updates a procedure' do
        page.all('td.right.collapsing')[1].click_link('Edit')

        fill_in 'Date', with: '2017-07-01'
        select 'Contraceptive', from: 'Procedure Name'
        fill_in 'Gestation', with: 12
        select 'Performed', from: 'Assistance'
        select trainer.name, from: 'Trainer'
        fill_in 'New Clinic Location', with: 'Mars'
        fill_in 'Notes', with: 'jkl;jkl;'

        click_on 'Submit'

        expect(page).to have_content 'Mars'
        expect(page).to have_content 'jkl;jkl;'
        expect(page).to have_content 'Contraceptive'
      end
    end
  end

  def login_resident
    visit '/'

    fill_in 'user_email', with: resident.email
    fill_in 'user_password', with: resident.password

    click_button 'Log in'
  end
end
