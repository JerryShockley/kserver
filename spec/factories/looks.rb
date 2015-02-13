# == Schema Information
#
# Table name: looks
#
#  id                 :integer          not null, primary key
#  title              :text
#  code               :text
#  short_desc         :text
#  desc               :text
#  usage_directions   :text
#  avg_rating         :float            default(0.0), not null
#  user_id            :integer
#  state              :text
#  look_reviews_count :integer
#  created_at         :datetime
#  updated_at         :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

def random_look_code
  %w(A B C D E F)[Random.rand(0..3)] + Random.rand(100..999).to_s
end



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
    state "active" 
    code {random_look_code}
    avg_rating {Random.rand(0.0..5.1).round(1)}
    look_reviews_count {Random.rand(1..500)}
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
