# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  sku                   :text             not null
#  brand                 :text
#  line                  :text
#  name                  :text
#  code                  :text
#  short_desc            :text
#  desc                  :text
#  size                  :text
#  manufacturer_sku      :text
#  state                 :text
#  is_multicolor         :boolean          default(FALSE)
#  avg_rating            :float            default(0.0), not null
#  price_cents           :integer          default(0), not null
#  cost_cents            :integer
#  product_reviews_count :integer
#  created_at            :datetime
#  updated_at            :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl


def random_product_image_filename
  ["img_1.png","img_2.png", "img_3.png", "img_4.jpg",  "img_5.jpg",  
        "img_6.jpg",  "img_7.jpg",  "img_8.jpg",  "img_9.jpg",  "img_10.jpg" ].shuffle.first
end


def create_colors(product_id)
  Random.rand(3..12).times do
    create :color, product_id: product_id
  end
end 


def random_code
  'P' + %w(F E L C)[Random.rand(0..3)] + %w(BS BB BL BR CC CT CS FO GL HS LB LT LI MA PE PO PR)[Random.rand(0..16)] + Random.rand(1000..9999).to_s
end

def fetch_user
  User.count > 0 ? User.find(Random.rand(User.first.id..User.last.id)) : build_stubbed(:user)
end



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
    short_desc {Faker::Lorem.sentences(2).join(".  ")}
    desc {Faker::Lorem.sentences(5).join("\n\n")}
    state "active"
    size {["1.7 FL. OZ.", "3.2 FL. OZ.", "2 FL. OZ.", "4 FL. OZ.", "2.4 FL. OZ.", "3.7 FL. OZ.", 
           "1.7 OZ.", "3.2 OZ.", "2 OZ.", "4 OZ.", "2.4 OZ.", "3.7 OZ."][Random.rand(0..11)]}
    price_cents {Random.new.rand(499..2399)}
    cost_cents {(price_cents * 0.8).to_i}
    avg_rating {Random.rand(1.0..5.1).round(1)}
    code {random_code}
    product_reviews_count {Random.rand(1..50)}
    is_multicolor false 
    
    after(:create) do |product, evaluator| 
      create_colors(product.id)
      # @usr_f ||= User.first.id
      # @usr_l ||= User.last.id
      # user_id = Random.rand(@usr_f..@usr_l)
      product.image = Image.create!(filename:  random_product_image_filename, dir: "product", user: fetch_user, 
                           name: "product image", model: "product")
    end
    
  
    factory :product_with_reviews do
      transient do
        # app_cnt {[1,4,2,15,2,3,1,5,9,7,2,12,4,3,3,4,2][Random.rand(16)]}
        review_cnt {Random.rand(1..50)}
      end
      
      after(:create) do |product, evaluator|
        create_list(:product_review, evaluator.review_cnt, product: product)
      end
    end
  end
end
