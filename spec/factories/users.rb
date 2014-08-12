# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)
#  last_name              :string(255)
#  role                   :integer
#

FactoryGirl.define do
  factory :user do
    first_name { role.to_s}
    last_name "User"
    sequence(:email) {|n| "#{role.to_s}#{n}@shockleynet.com"}
    # email {"#{role.to_s}@shockleynet.com"}
    password "foobar"
    password_confirmation "foobar"

    trait :sysadmin do
      role :sysadmin
    end
    
    trait :administrator do
      role :administrator
    end
    
    trait :teacher do
      role :teacher
    end
    
    trait :parent do
      role :parent1
    end
    
    trait :student do
      role :student
    end

    factory :sysadmin, traits: [:sysadmin]
    factory :administrator, traits: [:administrator]
    factory :teacher, traits: [:teacher]
    factory :parent, traits: [:parent]
    factory :student, traits: [:student]
  end
end
