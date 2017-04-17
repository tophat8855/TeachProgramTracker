require 'rails_helper'

RSpec.describe 'authentication', type: :feature do
  before do
    u = User.create(email: 'user@example.com',
            password: 'password',
            password_confirmation: 'password',
            name: 'Username',
            residency_location_id: 1)
  end

  context 'when the user is not authenticated' do
    it 'does not log the user in' do
      visit '/'

      fill_in 'user_email', with: 'fake-user@example.com'
      fill_in 'user_password', with: 'fake-password'

      click_button 'Log in'
      expect(page).to have_content 'Invalid Email or password.'
    end
  end

  context 'when the user is authenticated' do
    it 'logs the user in' do
      visit '/'

      fill_in 'user_email', with: 'user@example.com'
      fill_in 'user_password', with: 'password'

      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully.'
    end
  end
end
