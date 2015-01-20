# == Schema Information
#
# Table name: looks
#
#  id               :integer          not null, primary key
#  title            :text
#  short_desc       :text
#  desc             :text
#  usage_directions :text
#  user_id          :integer
#  active           :boolean
#  created_at       :datetime
#  updated_at       :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence :utitle do |n|
    "Really Awesome Look ##{n}"
  end
end
FactoryGirl.define do
  factory :look do
    title {generate :utitle}
    short_desc {Faker::Lorem.words(Random.rand(5..13)).join(" ")}
    desc {Faker::Lorem.paragraphs(Random.rand(2..4)).join("\n\n")}
    usage_directions {Faker::Lorem.sentences(3).join(".  ")}
    user_id 3
    active true
    
    factory :look_with_product_sets do

      count = Random.rand(1..8)
    
      after(:create) do |look, evaluator|
        count.times do
            look.product_sets << create(:product_set_with_clusters, user_id: evaluator.user_id)
        end
      end
      
    end
    
    
    
  end
end
