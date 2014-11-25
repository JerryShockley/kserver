require 'rails_helper'


# Feature: User edit
#   As a user
#   I want to edit my user profile
#   So I can change my email address
feature 'User edit', :devise do

  after(:each) do
    Warden.test_reset!
  end
 
  context "current_user is a customer" do
    # Scenario: User changes email address
    #   Given I am signed in
    #   When I change my email address
    #   Then I see an account updated message
    scenario 'change email address' do
      user = FactoryGirl.create(:user)
      login_as(user, :scope => :user)
      visit edit_userx_registration_path(user)
      fill_in 'Email', with: 'newemail@foo.com'
      click_button 'Update'
      expect(page).to have_content 'You updated your account successfully.'
    end

    # Scenario: User cannot edit another user's profile
    #   Given I am signed in
    #   When I try to edit another user's profile
    #   Then I see my own 'edit profile' page
    scenario "cannot edit another user's profile", :me do
      me = FactoryGirl.create(:cust)
      other = FactoryGirl.create(:cust, email: 'other@example.com')
      login_as(me, :scope => :user)
      visit edit_userx_registration_path(other)
      expect(page).to have_content 'Access denied'
    end  
  end

  # context "current_user is an administrator" do
  #
  #   scenario "can edit another user's profile", :me do
  #     me = FactoryGirl.create(:administrator)
  #     other = FactoryGirl.create(:cust, email: 'other@example.com')
  #     login_as(me, :scope => :user)
  #     visit edit_userx_registration_path(other)
  #     expect(page).to have_content 'Edit account'
  #     expect(page).to have_selector "input[value='#{other.email}']"
  #   end
  # end
   

end
