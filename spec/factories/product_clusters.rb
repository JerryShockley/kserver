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
    user_id 3
    product_set_id 1



    after(:create) do |product_cluster, evaluator|
      n = Random.rand(2..8)
      while n > 0 do
        product_cluster.product_apps << create(:product_app, role: evaluator.role, category: evaluator.category,
                                  user_id: evaluator.user_id )
        n -= 1
      end
      
    end
  end
end

