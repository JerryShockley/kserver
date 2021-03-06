module Features
  module SessionHelpers
    def sign_up_with(first_name, last_name, email, password)
      visit new_user_registration_path
      fill_in 'First name', with: first_name
      fill_in 'Last name', with: last_name
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign up'
    end

    def signin(email, password)
      visit new_user_session_path
      fill_in 'Email', with: email
      fill_in 'Password', with: password
      click_button 'Sign in'
    end
  end
end
