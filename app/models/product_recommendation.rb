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

class ProductRecommendation < ActiveRecord::Base
  include Comparable
   
  belongs_to :product_cluster, inverse_of: :product_recommendations
  belongs_to :product_app, inverse_of: :product_recommendations
  
  accepts_nested_attributes_for :product_app
  

  def <=>(other)
  self.priority <=> other.priority
  end
end
