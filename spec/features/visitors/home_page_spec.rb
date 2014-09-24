# Feature: Home page
#   As a visitor
#   I want to visit a home page
#   So I can learn more about the website
require 'rails_helper'

feature 'Home page' do

  # Scenario: Visit the home page
  #   Given I am a visitor
  #   When I visit the home page
  #   Then I see "Welcome"
  scenario 'visit the home page' do
    visit root_url
    expect(page).to have_content "ColorSistersSign inSign up"
  end

end
