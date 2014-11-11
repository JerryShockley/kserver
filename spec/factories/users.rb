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
require 'faker'

FactoryGirl.define do
  factory :user do
    first_name { Faker::Name.first_name}
    last_name {Faker::Name.last_name}
    # sequence(:email) {|n| "#{first_name.last_name}#{n}@foo.com"}
    email {"#{first_name.downcase}.#{last_name.downcase}@foo.com"}
    password "foobar"
    role :customer

    # trait :stubbed_profile do
    #   association :profile, factory: :profile, first_name: {first_name},
    #                         last_name: {last_name}, email: {email}, strategy: :build_stubbed
    # end

    trait :create_profile do
      profile { create :profile, first_name: first_name, last_name: last_name, email: email}
    end


    trait :sysadmin do
      role :sysadmin
    end
    
    trait :administrator do
      role :administrator
    end
    
    trait :editor do
      role :editor
    end
    
    trait :writer do
      role :writer
    end
    
    trait :cust do
      role :customer
    end

    # factory :stubbed_administator_profile, traits: [:administrator, :stubbed_profile]
    # factory :stubbed_customer_profile, traits: [:customer, :stubbed_profile]
    factory :create_administator_profile, traits: [:administrator, :create_profile]
    factory :create_customer_profile, traits: [:create_profile, :cust]
    factory :sysadmin, traits: [:sysadmin]
    factory :administrator, traits: [:administrator]
    factory :editor, traits: [:editor]
    factory :writer, traits: [:writer]
    factory :cust, traits: [:cust]
  end
end
