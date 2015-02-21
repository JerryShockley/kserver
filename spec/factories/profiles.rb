# == Schema Information
#
# Table name: profiles
#
#  id             :integer          not null, primary key
#  first_name     :text
#  last_name      :text
#  email          :text
#  street1        :text
#  street2        :text
#  city           :text
#  state          :text
#  postal_code    :text
#  receive_emails :boolean          default(TRUE)
#  created_at     :datetime
#  updated_at     :datetime
#  source         :string(255)
#  user_id        :integer
#  skin_color     :string(255)
#  eye_color      :string(255)
#  hair_color     :string(255)
#  age            :string(255)
#  skin_type      :string(255)
#  screen_name    :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :profile do
    first_name { Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    screen_name {"#{first_name} #{last_name}"}
    email {"#{first_name.downcase}.#{last_name.downcase}@foo.com"}
    street1 {Faker::Address.street_address}
    street2 ""
    city {Faker::Address.city}
    state {Faker::Address.state_abbr}
    postal_code {Faker::Address.zip_code}
    receive_emails true
    source { ["Maybelline trade show", "Google", "Nina's brilliant DC talk", "3/15/2014 email campaign", "Friend", 
              "Magazine Article",nil][rand(0..6)]}

    eye_color {["blue", nil, "brown", "green", nil, "hazel", "grey", "multi_colored"][Random.rand(7)]}
    hair_color {["black", "brown", nil, "caramel", "blond", "auburn", "chestnut", "red", "grey", "white"][Random.rand(8)]}
    age {["< 16", "16-20", "21-28", "29-36", nil, "37-42", "42-49", "50-59", "60-70", "> 70"][Random.rand(9)]}
    skin_type {["Oily/CloggedPores/Severe Breakouts All-Over", "Oily/Combination/Occasional Breakouts/Anti-Aging", 
                "Oily/Combination/Sensitive/Consistent Breakouts", "Oily/Combination/Sensitive/Occasional Breakouts", 
                "Normal/Sensitive/Red/Anti-Aging", "Normal/Anti-Aging", "Dry/Tired/Aging", 
                "Dry/SunDamaged/Aging", "Dry/Sensitive/Red/Aging", nil][Random.new.rand(9)]}
                
    after(:create) do |profile|
      profile.avatar = create(:image, filename: "head_shot.jpg", dir: "profile", user_id: User.first.id, name: "profile")
    end
    
    
    trait :with_stubbed_user do
      association :user, factory: :user, strategy: :build_stubbed
    end
  end
end
