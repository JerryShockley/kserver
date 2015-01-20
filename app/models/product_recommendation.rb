# == Schema Information
#
# Table name: product_recommendations
#
#  id                 :integer          not null, primary key
#  product_cluster_id :integer          not null
#  product_app_id     :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#

class ProductRecommendation < ActiveRecord::Base
  belongs_to :product_cluster, inverse_of: :product_recommendations
  belongs_to :product_app, inverse_of: :product_recommendations
end
