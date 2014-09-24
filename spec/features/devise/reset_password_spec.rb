require 'rails_helper'



feature "Password reset on signin page", :devise  do
  
  scenario "User enters invalid email" do
    visit new_user_password_path
    fill_in :new_password_email, with: "test_user@foo.com"
    click_button 'reset_password_submit'
    expect(page).to have_content "Email not found" 
    expect(page).to have_selector "input#new_password_email"    
  end
  
  scenario "User enters valid email" do
    visit new_user_password_path
    usr = create :cust
    fill_in :new_password_email, with: "#{usr.email}"
    click_button 'reset_password_submit'
    expect(page).to have_selector "a#new_session_forgot_password"    
  end
  
  
end
