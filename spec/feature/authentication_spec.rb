require 'rails_helper'

RSpec.describe 'authentication', type: :feature do
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
    let(:email) { 'user@example.com' }
    let(:password) { 'password' }

    before do
      FactoryGirl.create(:user, email: email, password: password, password_confirmation: password)
    end

    it 'logs the user in' do
      visit '/'

      fill_in 'user_email', with: email
      fill_in 'user_password', with: password

      click_button 'Log in'
      expect(page).to have_content 'Signed in successfully.'
    end
  end
end
