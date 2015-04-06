# == Schema Information
#
# Table name: product_clusters
#
#  id             :integer          not null, primary key
#  category       :text             not null
#  role           :text             not null
#  subrole        :string(255)
#  use_order      :integer
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
    use_order nil
    user_id 3
    product_set_id 3


    
    factory :cluster_create_apps do
      category nil
      role nil
      subrole nil
      user nil
      use_order nil
    
      transient do
        app_cnt 1
        product nil
      end
    
      after(:create) do  |cluster, evaluator|
        1.upto(evaluator.app_cnt) do |idx|
          pa = create(:product_app_create_product, role: evaluator.role, category: evaluator.category,
                                    user: evaluator.user, subrole: evaluator.subrole, prod: evaluator.product )

          cluster.product_apps << pa
          pr= pa.product_recommendations.first
          pr.priority = idx
          pr.save! 
        end
      end
    end  # cluster_create_apps factory

    
    factory :cluster_build_apps do
      category nil
      role nil
      subrole nil
      user nil
      use_order nil
    
      transient do
        app_cnt 1
        product nil
      end
    
      after(:stub) do  |cluster, evaluator|
        1.upto(evaluator.app_cnt) do |idx|
          pa = build_stubbed(:product_app_build_product, role: evaluator.role, category: evaluator.category,
                                    user: evaluator.user, subrole: evaluator.subrole )
        
          cluster.product_apps << pa
          pr= pa.product_recommendations.first
          pr.priority = idx
          # build(:product_recommendation, product_cluster: cluster, product_app: pa, priority: 1)
        end
      end
    end # cluster_build_apps factory
    
    
    factory :product_cluster_with_product_apps do
      after(:create) do |product_cluster, evaluator|
        1.upto(Random.rand(2..8)) do |i|
          if Product.count > 1
            product = Product.find(Random.rand(Product.first.id..Product.last.id))
            color = product.colors.shuffle.first
            pa = create(:product_app_create_product, role: evaluator.role, category: evaluator.category,
                                      user_id: evaluator.user_id, product: product, color_id: color.id, 
                                      subrole: evaluator.subrole )
          else
            pa = create(:product_app_create_product, role: evaluator.role, category: evaluator.category,
                                      user_id: evaluator.user_id, subrole: evaluator.subrole )
          end
          product_cluster.product_apps << pa
          pr= pa.product_recommendations.where(product_cluster_id: product_cluster.id).first
          pr.priority = i
          pr.save! 
        end
      end
    end
  end
end

