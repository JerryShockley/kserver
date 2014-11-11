
FactoryGirl.define do
  factory :profile_form do
    first_name { Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    email {"#{first_name}.#{last_name}@foo.com"}
    street1 {Faker::Address.street_address}
    street2 ""
    city {Faker::Address.city}
    state {Faker::Address.state_abbr}
    postal_code {Faker::Address.zip_code}
    receive_emails true
    role :cust
    password "foobar"
  end
end
