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

# Read about factories at https://github.com/thoughtbot/factory_girl



FactoryGirl.define do
  factory :product_recommendation do
    product_cluster nil
    product_app nil
    
  end
end
