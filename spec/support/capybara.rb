class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil
  
  def self.connection
    @@shared_connection || retrieve_connection
  end 
end
ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

include Warden::Test::Helpers
Warden.test_mode! 
Capybara.javascript_driver = :poltergeist
Capybara.asset_host = 'http://localhost:3000'