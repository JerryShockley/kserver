require 'rails_helper'


# Feature: User delete
#   As a user
#   I want to delete my user profile
#   So I can close my account
feature 'User delete', :devise, :js do

  after(:each) do
    Warden.test_reset!
  end

  # Scenario: User can delete own account
  #   Given I am signed in
  #   When I delete my account
  #   Then I should see an account deleted message
  scenario 'user can delete own account' do
    skip 'skip a slow test'
    user = FactoryGirl.create(:cust)
    login_as(user, :scope => :user)
    # page.driver.submit :delete, send(userx_registration_path(user), User)
    visit edit_userx_registration_path(user.id)
    click_button 'Cancel my account'
    page.driver.browser.switch_to.alert.accept
    expect(page).to have_content 'Bye! Your account was successfully cancelled. We hope to see you again soon.'
  end

end




