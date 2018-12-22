require 'rails_helper'

RSpec.describe 'Procedure Features', type: :feature do
  let!(:location)  { FactoryBot.create(:residency_location) }
  let!(:location2) { FactoryBot.create(:residency_location) }
  let!(:resident)  { FactoryBot.create(:user,
    name: 'Resident Name',
    email: 'resident@email.com',
    residency_location_id: location.id,
    status: 'R2',
    password: 'password',
    password_confirmation: 'password')
  }

  let!(:other_resident)  { FactoryBot.create(:user,
    name: 'Other Resident Name',
    email: 'other@example.com',
    residency_location_id: location.id,
    status: 'R2',
    password: 'password',
    password_confirmation: 'password')
  }

  let!(:trainer) { FactoryBot.create(:user,
    name: 'Trainer Name',
    email: 'trainer@email.com',
    residency_location_id: location.id,
    trainer: true,
    password: 'password',
    password_confirmation: 'password')
  }

  let!(:procedure_1) { FactoryBot.create(:procedure,
    resident_name: resident.name,
    resident_status: resident.status,
    user_id: resident.id,
    clinic_location: location.name,
    trainer_name: trainer.name
    )
  }

  let!(:procedure_2) { FactoryBot.create(:procedure,
    resident_name: resident.name,
    resident_status: resident.status,
    name: 'MVA',
    user_id: resident.id,
    clinic_location: location2.name,
    trainer_name: trainer.name
    )
  }

  let!(:other_procedure) { FactoryBot.create(:procedure,
    resident_name: other_resident.name,
    resident_status: other_resident.status,
    name: 'MVA',
    user_id: other_resident.id,
    clinic_location: location2.name,
    trainer_name: trainer.name
    )
  }
  let!(:procedure_with_custom_trainer) { FactoryBot.create(:procedure,
    resident_name: resident.name,
    resident_status: resident.status,
    name: 'MVA',
    user_id: resident.id,
    clinic_location: location2.name,
    trainer_name: 'Custom Trainer'
    )
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

    it 'does not show procedures for other users' do
      expect(page).to_not have_content other_resident.name
    end
  end

  describe 'show procedure details' do
    it 'shows the details of a procedure' do
      link_column = page.all('td.right.collapsing')[2]

      link_column.click_link('View')

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

      fill_in 'Date', with: Date.today
      select 'IUD', from: 'Procedure Name'
      fill_in 'Gestation', with: 8
      select 'Observed', from: 'Assistance'
      select trainer.name, from: 'Trainer'
      select location2.name, from: 'Clinic Location'
      fill_in 'Notes', with: 'asdfasdf'
      click_on 'Submit'

      first_procedure_row = page.all('tr')[2]

      expect(first_procedure_row).to have_content 'asdf'
      expect(first_procedure_row).to have_content location2.name
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

    context 'with a custom trainer' do
      it 'creates a procedure' do
        click_link 'Record New Procedure'

        fill_in 'Date', with: '2017-07-01'
        select 'IUD', from: 'Procedure Name'
        fill_in 'Gestation', with: 8
        select 'Observed', from: 'Assistance'

        fill_in 'New Trainer', with: 'Not-in-system Trainer'

        select location.name, from: 'Clinic Location'
        fill_in 'Notes', with: 'asdfasdf'

        click_on 'Submit'

        expect(page).to have_content 'Not-in-system Trainer'
      end
    end
  end

  describe 'update procedure' do
    it 'updates a procedure with desired details' do
      link_column = page.all('td.right.collapsing')[2]
      link_column.click_link('Edit')

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
        link_column = page.all('td.right.collapsing')[2]

        link_column.click_link('Edit')

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

    context 'with a custom trainer' do
      it 'updates a procedure' do
        link_column = page.all('td.right.collapsing')[2]

        link_column.click_link('Edit')

        fill_in 'Date', with: '2017-07-01'
        select 'Contraceptive', from: 'Procedure Name'
        fill_in 'Gestation', with: 12
        select 'Performed', from: 'Assistance'
        select 'Custom Trainer', from: 'Trainer'
        fill_in 'Notes', with: 'jkl;jkl;'

        click_on 'Submit'

        updated_row = page.all('tr.tablerow')[2]

        expect(updated_row).to have_content 'jkl;jkl;'
        expect(updated_row).to have_content 'Contraceptive'
        expect(updated_row).to have_content 'Custom Trainer'
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
