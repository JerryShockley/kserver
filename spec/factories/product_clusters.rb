# == Schema Information
#
# Table name: product_clusters
#
#  id             :integer          not null, primary key
#  category       :text             not null
#  role           :text             not null
#  user_id        :integer
#  product_set_id :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl
require 'core_ext/string'

ROLES_HASH ||= {
          face: ProductApp::FACE_ROLES.map { |e| e.snakecase.to_sym},
          eyes: ProductApp::EYE_ROLES.map { |e| e.snakecase.to_sym},
          lips: ProductApp::LIP_ROLES.map { |e| e.snakecase.to_sym},
          cheeks: ProductApp::CHEEK_ROLES.map { |e| e.snakecase.to_sym}
              }
      
SIZE ||= {
          face: ProductApp::FACE_ROLES.size - 1,
          eyes: ProductApp::EYE_ROLES.size - 1,
          lips: ProductApp::LIP_ROLES.size - 1,
          cheeks: ProductApp::CHEEK_ROLES.size - 1 
        }
      

FactoryGirl.define do
  factory :product_cluster do
    category {[:face, :eyes, :lips, :cheeks][Random.rand(3)]}
    role  {ROLES_HASH[category][Random.rand(SIZE[category])]}
    subrole nil
    user_id 3
    product_set_id 1



    after(:create) do |product_cluster, evaluator|
      n = Random.rand(2..8)
      app_hash={}
      # ROLES_HASH.keys.each do {|category| app_hash[category] = ProductApp.by_category(category)}
      i=1
      while i <= n do
        product = Product.find(Random.rand(Product.first.id..Product.last.id))
        color = product.colors.shuffle.first
        ###### TODO load existing products from db vs creating unique
        pa = create(:product_app, role: evaluator.role, category: evaluator.category,
                                  user_id: evaluator.user_id, product: product, color_id: color.id, 
                                  subrole: evaluator.subrole )
        product_cluster.product_apps << pa
        pa.product_recommendations.first.priority = i
        pa.save!
        i += 1
      end
    end
  end
end

