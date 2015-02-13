# == Schema Information
#
# Table name: product_sets
#
#  id         :integer          not null, primary key
#  look_id    :integer          not null
#  skin_color :text             not null
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
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
  factory :product_set do
    look_id 1
    skin_color {Faker::Number.number(6)}
    user_id 3
    
    factory :product_set_with_clusters do

      ignore do
        category_roles {{face: [:foundation, :primer, :powder],
                          eyes: [:basic_shadow, :highlight_shadow, :liner_bottom, :liner_top],
                          lips: [:gloss, :lipstick, :pencil],
                          cheeks: [:blush]}}
        # user_id {3}
      end
    
      after(:create) do |product_set, evaluator|
        # cat_cnt = Random.rand(0..3)
        # evaluator.category_roles.keys
        evaluator.category_roles.each do |category, roles|
          roles.each do |role|
            product_set.product_clusters << create(:product_cluster, category: category, 
                                                   role: role, user_id: evaluator.user_id)
          
          end
        end
      end
      
    end
  end
end
