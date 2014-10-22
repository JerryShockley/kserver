require 'rails_helper'

# Feature: Sign up
#   As a visitor
#   I want to sign up
#   So I can visit protected areas of the site
feature 'Sign Up', :devise do

  # Scenario: Visitor can sign up with valid email address and password
  #   Given I am not signed in
  #   When I sign up with a valid email address and password
  #   Then I see a successful sign up message
  scenario 'visitor can sign up with valid first name, last name, email address and password' do
    
    sign_up_with('Joe', 'Allenator', 'test@example.com', 'please123')
    expect(page).to have_content 'Welcome to ColorSisters Joe!'
  end

  # Scenario: Visitor cannot sign up with invalid email address
  #   Given I am not signed in
  #   When I sign up with an invalid email address
  #   Then I see an invalid email message
  scenario 'visitor cannot sign up with invalid email address format' do
    sign_up_with('Joe', 'Allenator', 'bogus', 'please123')
    expect(page).to have_content 'Email is invalid'
  end

  # Scenario: Visitor cannot sign up without an email confirmation
  #   Given I am not signed in
  #   When I sign up without an email address confirmation
  #   Then I see an invalid email confirmation message
  scenario 'visitor cannot sign up with a blank email address' do
    sign_up_with('Joe', 'Allenator',  '', 'please123')
    expect(page).to have_content "Email can't be blank"
  end

  # Scenario: Visitor cannot sign up without password
  #   Given I am not signed in
  #   When I sign up without a password
  #   Then I see a missing password message
  scenario 'visitor cannot sign up without password' do
    sign_up_with('Joe', 'Allenator', 'test@example.com', '')
    expect(page).to have_content "Password can't be blank"
  end

  # Scenario: Visitor cannot sign up with a short password
  #   Given I am not signed in
  #   When I sign up with a short password
  #   Then I see a 'too short password' message
  scenario 'visitor cannot sign up with a short password' do
    sign_up_with('Joe', 'Allenator', 'test@example.com', 'plea')
    expect(page).to have_content "Password is too short"
  end

end
