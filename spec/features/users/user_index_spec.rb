require 'rails_helper'

# Feature: User index page
#   As a user
#   I want to see a list of users
#   So I can see who has registered
describe 'Registrations index page', :devise do

  after(:each) do
    Warden.test_reset!
    # @request.env["devise.mapping"] = Devise.mappings[:user]
  end

  feature 'manage user registrations' do
    # let(:user) { create :administrator }
    # let(:other_user) { create :cust }

    scenario 'edit another user registration' do
      user = create :administrator
      other_user = create :cust
      login_as(user, scope: :user)
      visit users_path
      click_link "edit_#{other_user.id}"
      expect(page).to have_content "Edit User"
      expect(page).to have_field "user_email", with: other_user.email
    end
  
    context 'clicking the delete link on another user\'s registration record' do
      
      
      scenario 'removes the selected registration record', js: true do
        user = create :administrator
        other_user = create :cust
        login_as(user, scope: :user)
        visit users_path
        click_link "delete_#{other_user.id}"
        page.driver.browser.switch_to.alert.accept
        u = User.find(other_user.id)
        # The selected registration is removed from the db
        expect(User.find(other_user.id)).to raise_exception(ActiveRecord::RecordNotFound)
        # We are returned to the index page and it contains our registration
        expect(page).to have_content "edit_#{user.id}"
        # Flash message is displayed
        expect(page).to have_content "destroyed user registration belonging to #{other_user.name} with email #{other_user.email}."
        # record is removed from index page
        expect(page).to_not have_content "edit_#{other_user.id}"
      end
    

      scenario 'removes the record from the db' do
      end

      scenario 'returns to the index page' do
      end

      scenario 'displays confimation message' do
      end

      scenario 'removes the record from the index page' do
      end

    end
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
  
  
  
  
  
  

end
