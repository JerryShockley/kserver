# == Schema Information
#
# Table name: products
#
#  id             :integer          not null, primary key
#  sku            :text             not null
#  brand          :text
#  line           :text
#  name           :text
#  shade_name     :text
#  shade_code     :text
#  short_desc     :text
#  desc           :text
#  image_usage_id :integer
#  hex_color_val  :text
#  active         :boolean
#  price_cents    :integer          default(0), not null
#  cost_cents     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:pname) do |n|
    "Very Cool Product #{n}"
  end
end

FactoryGirl.define do
  factory :product do
    sku  {Faker::Number.number(10)}
    brand  {["Maybelline", "Loreal", "Mac", "Covergirl", "Clinique", "Diorskin", "Maxfactor", "Estee Lauder", "Lancome"][Random.new.rand(8)]}
    line  {["Age Defying", "Moisture +", "Tropical Heat", "Desire", "Hidden Treasure", "Ice", "Floating Petals", "Intentions", "Risque"][Random.new.rand(8)]}
    name {generate :pname}
    shade_name {["Beige", "Nude", "Porcelin Ivory", "Ivory", "Creamy Natural", "Sandy Beige", "Medium Buff", "Pure Beige", "Sun Beige",
                "Turquiose Sea", "Earthly Taupe", "Tuscan Lavendar", "Golden Halo", "Blue Blazes", "Pink Wink"][Random.new.rand(14)]}
    shade_code {"n#{Faker::Number.number(3)}"}
    short_desc {Faker::Lorem.sentences(2).join(".  ")}
    desc {Faker::Lorem.sentences(5).join("\n\n")}
    image_usage_id nil
    # {"product_imgs/thumbs" + ["img_1.png", "img_2.png", "img_3.png", "img_4.jpg", "img_5.jpg", "img_6.jpg", "img_7.jpg", "img_8.jpg",
    #           "img_9.jpg", "img_10.jpg"][Random.new.rand(9)]}
    hex_color_val {["#F1C7A0", "#E6B48B", "#EDC196", "#DCA785", "#CE9F7A", "#CA9366", "#B67A4B", "#81471B", "#BBC9E1",
                    "#77569F", "#E2A86C", "#02363D", "#FFBFB6", "#EFB29B", "#AEBBD4", "#242F3F"][Random.new.rand(15)]}
    active true
    price_cents {Random.new.rand(499..2399)}
    cost_cents {(price_cents * 0.8).to_i}
    
    
    factory :product_with_reviews do
      ignore do
        # app_cnt {[1,4,2,2,2,3,1,5,1,2,2,1,4,3,3,4,2][Random.rand(16)]}
        app_cnt 2
      end
      
      
      after(:create) do |product, evaluator|
        create_list(:product_review, evaluator.app_cnt, product: product, user_id: Random.rand(10..180))
      end
      
    end
    
    
    factory :product_with_apps do
      
      ignore do
        category {:face}
        role {:base_shadow}
        user_id {3}
        app_cnt {[1,1,1,2,2,3,1,1,1,2,2,1,1,1,3,1,2][Random.rand(16)]}
      end
      
      after(:create) do |product, evaluator|
        create_list(:product_app, evaluator.app_cnt, product: product, category: evaluator.category, 
                    role: evaluator.role, user_id: evaluator.user_id)
      end
    end
  end
end
