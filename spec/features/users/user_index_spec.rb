require 'rails_helper'

# Feature: User index page
#   As a user
#   I want to see a list of users
#   So I can see who has registered
feature 'User index page', :devise do

  after(:each) do
    Warden.test_reset!
    # @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  # Scenario: User listed on index page
  #   Given I am signed in
  #   When I visit the user index page
  #   Then I see my own email address
  scenario 'user sees own email address' do
    user = create :administrator
    login_as(user, scope: :user)
    visit users_path
    expect(page).to have_content user.email
    expect(page).to have_selector "a", text: "Edit"
    expect(page).to have_selector "a", text: "Delete"    
  end
  
  
  scenario 'admin edits another user account' do
    user = create :administrator
    other_user = create :cust
    login_as(user, scope: :user)
    visit users_path
    click_link "edit_#{other_user.id}"
    expect(page).to have_content "Edit User"
    expect(page).to have_field "user_email", with: other_user.email
    
  end
  
  
  scenario 'admin deletes another user account' do
    user = create :administrator
    other_user = create :cust
    login_as(user, scope: :user)
    visit users_path
    click_link "delete_#{other_user.id}"
    #TODO Add the appropriate expectation here after fixing registration_controller destroy render problem
    # expect(page).to have_content other_user.email

  end
  
  

end
