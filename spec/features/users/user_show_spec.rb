require 'rails_helper'


# Feature: User profile page
#   As a user
#   I want to visit my user profile page
#   So I can see my personal account data
feature 'User profile page', :devise do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User sees own profile
  #   Given I am signed in
  #   When I visit the user profile page
  #   Then I see my own email address
  scenario 'user sees own profile' do
    user = FactoryGirl.create(:user)
    login_as(user, :scope => :user)
    visit userx_registration_path(user.profile.id)
    expect(page).to have_content 'User'
    expect(page).to have_content user.email
  end

  # Scenario: User cannot see another user's profile
  #   Given I am signed in
  #   When I visit another user's profile
  #   Then I see an 'access denied' message
  scenario "user cannot see another user's profile" do
    me = FactoryGirl.create(:cust)
    other = FactoryGirl.create(:cust, email: 'other@example.com')
    login_as(me, :scope => :user)
    Capybara.current_session.driver.header 'Referer', '/welcome/index'
    visit userx_registration_path(other.profile)
    expect(page).to have_content "Access denied.×"
  end

end
