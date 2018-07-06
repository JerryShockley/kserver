# == Schema Information
#
# Table name: product_apps
#
#  id         :integer          not null, primary key
#  role       :string(255)      not null
#  subrole    :string(255)
#  product_id :integer          not null
#  user_id    :integer
#  color_id   :integer
#  category   :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_bot







FactoryBot.define do
  factory :product_app do
    category [:face, :eyes, :lips, :cheeks][Random.rand(3)]
    # association product, factory: :product
    role  {ProductEnumerations::ROLES_HASH[category][Random.rand(SIZE[category])]}
    user { User.count > 0 ? User.find(Random.rand(User.first.id..User.last.id)) : build_stubbed(:user) } 
    color 
    subrole nil
    
    
    factory :product_app_build_product do
    
      transient do
        is_multicolor false
        prod nil
      end
      
      product {prod.nil? ? build_stubbed(:product, is_multicolor: is_multicolor) : prod}

    end

    
    
    factory :product_app_create_product do
    
      transient do
        is_multicolor false
        prod nil
      end
      
      product {prod.nil? ? create(:product, is_multicolor: is_multicolor) : prod}
    end
    
    
  end
end
