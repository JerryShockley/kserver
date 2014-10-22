require 'rails_helper'

# Feature: User index page
#   As a user
#   I want to see a list of users
#   So I can see who has registered
describe 'Registrations index page', :devise do

  let!(:user1) {create :administrator, first_name: "Jerry", last_name: "Shockley"}
  let!(:user2) {create :cust, first_name: "Sam", last_name: "Bowers"}
  let!(:user3) {create :cust, first_name: "Pete", last_name: "Wilcox"}

  after(:each) do
    Warden.test_reset!
    # @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  before(:each) do
    login_as(user1, scope: :user)
  end
  

  feature 'manage user registrations' do

    scenario 'edit another user registration' do
      visit users_path
      click_link "edit_#{user2.id}"
      expect(page).to have_content "Edit User"
      expect(page).to have_field "user_email", with: user2.email
    end
  
    context 'clicking another user record\'s delete link' do
      
      
      scenario 'removes the selected registration record', js: true do
        visit users_path
        click_link "delete_#{user2.id}"
        # The selected registration is removed from the db
        expect{User.find(user2.id)}.to raise_exception(ActiveRecord::RecordNotFound)
        # We are returned to the index page and it contains our registration
        # expect(page).to have_selector "edit_#{user.id}"
        expect(page).to have_xpath("//*[@id='edit_#{user1.id}']")
        # Flash message is displayed
        expect(page).to have_content "destroyed user registration belonging to #{user2.name} with email #{user2.email}."
        # record is removed from index page
        expect(page).to_not have_xpath("//*[@id='edit_#{user2.id}']")
      end
    
      context 'Searching and sorting the data' do
        scenario 'adding single column sort and search', js: true do
          visit users_path
          # find :xpath, "//*[@id='q_s_0_name']"
          select 'Last name', :from => "q_s_0_name"
          select 'descending', :from => "q_s_0_dir"

          select 'Last name', :from => "q_c_0_a_0_name"
          select 'contains', :from => "q_c_0_p"
          fill_in("q_c_0_v_0_value", :with =>  "e")
         
          click_button('Search')
          
          # Test the sorting and conditions form
          user_last_names = page.all('table#users.admin tbody tr td:nth-child(1)').map{|td| td.text}
          expect(user_last_names.size).to eq(2)
          expect(user_last_names[0]).to eq(user1.last_name)
          expect(user_last_names[1]).to eq(user2.last_name)
         
          # Count sort_link headers
          sort_link_count = page.all("thead tr .sort_link:nth-child(1n)").size
          expect(sort_link_count).to eq(7)
          links = page.all("thead tr th:nth-child(1n)")
         
          # Make sure we have the operations header too!
          expect(links.size).to eq(sort_link_count + 1)
         
          # Make sure sort_link column header links work
          click_link("First name")
          click_link("First name")
          user_last_names = page.all('table#users.admin tbody tr td:nth-child(1)').map{|td| td.text}
          expect(user_last_names[0]).to eq(user2.last_name)
          expect(user_last_names[1]).to eq(user1.last_name)
          
      # ****  Test the sort js links
          
          # test js add sort links on search form
          click_link("add_sort_fields")
          click_link("add_sort_fields")
          sort_row_count = page.all('.sort_row:nth-child(1n)').size
          expect(sort_row_count).to eq 3
         
          # check that the id's are being incremented correctly
          expect(page.has_xpath?("//select[@id='q_s_0_name']")).to be true
          expect(page.has_xpath?("//select[@id='q_s_1_name']")).to be true
          expect(page.has_xpath?("//select[@id='q_s_2_name']")).to be true
          # Test removing the 3rd sort row
          # find('a.remove_sort_fields:nth-child(3)').click
          expect(page.has_xpath?("//*[@id='sort_fieldset']/div[@class='field'][3]")).to be true
          within(:xpath, "//*[@id='sort_fieldset']/div[@class='field'][3]") do
            click_link("Remove")
          end
         
           # save_and_open_page
          sort_row_count = nil
          sort_row_count = page.all('.sort_row:nth-child(1n)').size
          expect(sort_row_count).to eq 2
          expect(page.has_xpath?("//select[@id='q_s_0_name']")).to be true
          expect(page.has_xpath?("//select[@id='q_s_1_name']")).to be true
         
          # Remove 2nd sort row and validate the the 1st contains values
          expect(page.has_xpath?("//*[@id='sort_fieldset']/div[@class='field'][2]")).to be true
          within(:xpath, "//*[@id='sort_fieldset']/div[@class='field'][2]") do
            click_link("Remove")
          end
          sort_row_count = nil
          sort_row_count = page.all('.sort_row:nth-child(1n)').size
          expect(sort_row_count).to eq 1
          expect(page.has_xpath?("//select[@id='q_s_0_name']")).to be true
          
          # Click remove on the single remaining row and the values should be set to default
          expect(find(:xpath, "//select[@id='q_s_0_name']").value).to eq('first_name')
          expect(find(:xpath, "//*[@id='q_s_0_dir']").value).to eq('desc')
          expect(page.has_xpath?("//*[@id='sort_fieldset']/div[@class='field'][1]")).to be true
          within(:xpath, "//*[@id='sort_fieldset']/div[@class='field'][1]") do
            click_link("Remove")
          end
          expect(find(:xpath, "//select[@id='q_s_0_name']").value).to eq('')
          expect(find(:xpath, "//*[@id='q_s_0_dir']").value).to eq('asc')
      
    # ****  Test the conditions js links
          
          # test js add conditions links on search form
          click_link("add_condition_fields")
          click_link("add_condition_fields")
          condition_row_count = page.all('.condition_row:nth-child(1n)').size
          expect(condition_row_count).to eq 3
         
          # check that the id's are being incremented correctly
          expect(page.has_xpath?("//select[@id='q_c_0_a_0_name']")).to be true
          expect(page.has_xpath?("//select[@id='q_c_1_a_0_name']")).to be true
          expect(page.has_xpath?("//select[@id='q_c_2_a_0_name']")).to be true

          # Test removing the 3rd condition row
          # find('a.remove_condition_fields:nth-child(3)').click
          expect(page.has_xpath?("//*[@id='condition_fieldset']/div[@class='field'][3]")).to be true
          within(:xpath, "//*[@id='condition_fieldset']/div[@class='field'][3]") do
            click_link("Remove")
          end
         
          # Remove the 2nd row
          condition_row_count = nil
          condition_row_count = page.all('.condition_row:nth-child(1n)').size
          expect(condition_row_count).to eq 2
          expect(page.has_xpath?("//select[@id='q_c_0_a_0_name']")).to be true
          expect(page.has_xpath?("//select[@id='q_c_1_a_0_name']")).to be true
         
          # Remove 2nd condition row and validate the the 1st contains values
          expect(page.has_xpath?("//*[@id='condition_fieldset']/div[@class='field'][2]")).to be true
          within(:xpath, "//*[@id='condition_fieldset']/div[@class='field'][2]") do
            click_link("Remove")
          end
          condition_row_count = nil
          condition_row_count = page.all('.condition_row:nth-child(1n)').size
          expect(condition_row_count).to eq 1
          expect(page.has_xpath?("//select[@id='q_c_0_a_0_name']")).to be true
          
          # Click remove on the single remaining row and the values should be set to default
          expect(find(:xpath, "//select[@id='q_c_0_a_0_name']").value).to eq('last_name')
          expect(find(:xpath, "//select[@id='q_c_0_p']").value).to eq('cont')
          expect(find(:xpath, "//input[@id='q_c_0_v_0_value']").value).to eq('e')
          expect(page.has_xpath?("//*[@id='condition_fieldset']/div[@class='field'][1]")).to be true
          within(:xpath, "//*[@id='condition_fieldset']/div[@class='field'][1]") do
            click_link("Remove")
          end
          expect(find(:xpath, "//select[@id='q_c_0_a_0_name']").value).to eq('')
          expect(find(:xpath, "//select[@id='q_c_0_p']").value).to eq('cont')
          expect(find(:xpath, "//input[@id='q_c_0_v_0_value']").value).to eq('')
          
        end
      end
    
    end
  end
  # Scenario: User listed on index page
  #   Given I am signed in
  #   When I visit the user index page
  #   Then I see my own email address
  scenario 'user sees own email address' do
    visit users_path
    expect(page).to have_content user1.email
    expect(page).to have_selector "a", text: "Edit"
    expect(page).to have_selector "a", text: "Delete"    
  end
  
  
  
  
  
  

end
