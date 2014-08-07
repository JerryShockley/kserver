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
