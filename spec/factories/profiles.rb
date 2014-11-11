# == Schema Information
#
# Table name: profiles
#
#  id             :integer          not null, primary key
#  first_name     :string(255)
#  last_name      :string(255)
#  email          :string(255)
#  street1        :string(255)
#  street2        :string(255)
#  city           :string(255)
#  state          :string(255)
#  postal_code    :string(255)
#  receive_emails :boolean          default(TRUE)
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :profile do
    first_name { Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    email {"#{first_name.downcase}.#{last_name.downcase}@foo.com"}
    street1 {Faker::Address.street_address}
    street2 ""
    city {Faker::Address.city}
    state {Faker::Address.state_abbr}
    postal_code {Faker::Address.zip_code}
    receive_emails true
    source { ["Maybelline trade show", "Google", "Nina's brilliant DC talk", "3/15/2014 email campaign", "Friend", 
              "Magazine Article",nil][rand(0..6)]}
    
    trait :with_stubbed_user do
      association :user, factory: :user, strategy: :build_stubbed
    end
  end
end
