include Warden::Test::Helpers
Warden.test_mode! 
Capybara.javascript_driver = :poltergeist
Capybara.asset_host = 'http://localhost:3000'