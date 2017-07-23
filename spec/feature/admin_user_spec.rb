require 'rails_helper'

RSpec.describe 'Admin management of users', type: :feature do
  let!(:location1) { FactoryGirl.create(:residency_location) }
  let!(:location2) { FactoryGirl.create(:residency_location) }
  let!(:resident) { FactoryGirl.create(:user,
    name: 'Resident Name',
    email: 'resident@email.com',
    residency_location_id: location1.id,
    status: 'R2',
    password: 'password',
    password_confirmation: 'password')
  }

  let!(:trainer) { FactoryGirl.create(:user,
    name: 'Trainer Name',
    email: 'trainer@email.com',
    residency_location_id: location1.id,
    trainer: true,
    password: 'password',
    password_confirmation: 'password')
  }

  let!(:procedure) { FactoryGirl.create(:procedure,
    resident_name: resident.name,
    resident_status: resident.status,
    user_id: resident.id,
    trainer_id: trainer.id,
    clinic_location: location1.name)
  }

  before do
    login_admin

    click_on 'Users'
  end

  describe 'list of users' do
    it 'shows all users and their corresponding data' do
      expect(page).to have_content 'Residents'
      expect(page).to have_content 'Resident Name'
      expect(page).to have_content 'resident@email.com'
      expect(page).to have_content location1.name
      expect(page).to have_content 'R2'

      expect(page).to have_content 'Trainer Name'
      expect(page).to have_content 'trainer@email.com'
      expect(page).to have_content location1.name
      expect(page).to have_content 'Trainer'
    end
  end

  describe 'user info page' do
    it 'shows the user information' do
      page.all('td.right.collapsing')[1].click_link('View')

      expect(page).to have_content 'Resident Name'
      expect(page).to have_content 'resident@email.com'
      expect(page).to have_content location1.name
      within 'tbody' do
        expect(page).to have_content procedure.name
        expect(page).to have_content procedure.date.to_s
      end
    end
  end

  describe 'user creation' do
    it 'creates user with desired attributes' do
      click_link 'Invite New User'

      fill_in 'Name', with: 'New User'
      fill_in 'Email', with: 'new_user@email.com'
      select 'R3', from: 'Status'
      select location1.name, from: 'Residency Location'
      check 'Trainer'
      check 'Admin'

      click_on 'Invite'

      expect(page).to have_content 'new_user@email.com'
    end

    context 'when creating a user with a duplicate email' do
      it 'shows a flash warning that email has already been taken' do
        click_link 'Invite New User'

        fill_in 'Name', with: 'New User'
        fill_in 'Email', with: resident.email
        select 'R3', from: 'Status'
        select location1.name, from: 'Residency Location'
        check 'Trainer'
        check 'Admin'

        click_on 'Invite'

        expect(page).to have_content 'Email has already been taken'
      end
    end
  end

  describe 'updating a user' do
    context 'when attributes are correct' do
      it 'updates user with desired attributes' do
        page.all('td.right.collapsing')[1].click_link('Edit')

        fill_in 'Name', with: 'Updated Name'
        fill_in 'Email', with: 'updated_email@email.com'
        select 'R3', from: 'Status'
        select location2.name, from: 'Residency Location'

        click_on 'Submit'

        expect(page).to have_content 'updated_email@email.com'
        expect(page).to have_content 'Updated Name'
        expect(page).to have_content location2.name
        expect(page).to have_content 'R3'
      end
    end

    context 'when the email is a duplicate' do
      it 'stays on the page and displays error message' do
        page.all('td.right.collapsing')[1].click_link('Edit')

        fill_in 'Name', with: 'Updated Name'
        fill_in 'Email', with: trainer.email

        click_on 'Submit'

        expect(page).to have_content 'Email has already been taken'
      end
    end
  end

  def login_admin
    FactoryGirl.create(:user,
      email: 'test@email.com',
      password: 'password',
      password_confirmation: 'password',
      admin: true,
      residency_location_id: location1.id
    )
    visit '/'

    fill_in 'user_email', with: 'test@email.com'
    fill_in 'user_password', with: 'password'

    click_button 'Log in'
  end
end
