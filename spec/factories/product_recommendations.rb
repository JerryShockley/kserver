# == Schema Information
#
# Table name: product_recommendations
#
#  id                 :integer          not null, primary key
#  product_cluster_id :integer          not null
#  product_app_id     :integer          not null
#  priority           :integer          default(50), not null
#  created_at         :datetime
#  updated_at         :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_bot



FactoryBot.define do
  factory :product_recommendation do
    product_cluster nil
    product_app nil
    priority 1
    
    # factory :product_recommendation_with_product_app do
    #   transient do
    #     role  {product_cluster.nil? ? nil : product_cluster.role}
    #     category  {product_cluster.nil? ? nil : product_cluster.category}
    #     subrole {product_cluster.nil? ? nil : product_cluster.subrole}
    #   end
    #
    #   after(:create) do |product_rec, evaluator|
    #     product_rec.product_app = create(:product_app, role: evaluator.role, category: evaluator.category,
    #                                       subrole: evaluator.subrole)
    #     product_rec.save!
    #   end
    # end
    
  end
end
