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

class ProductCluster < ActiveRecord::Base
  belongs_to :user
  has_many :product_recommendations, dependent: :destroy, inverse_of: :product_cluster
  has_many :product_apps, :through => :product_recommendations
  
  
  def self.by_category(category)
    # ProductCluster.includes(:product_apps).where("product_clusters.category = ?", ProductApp.categories[category.to_s].to_s).order(role: :asc)
    ProductCluster.includes(:product_apps).where("category = ?", 
                  category.to_s).order(role: :asc)
    
  end 

  #
  # def product_apps_by_role(role)
  #   return product_apps if role.blank?
  #   product_apps.find_all { |pc| pc.role == role}
  # end

  
  # def product_apps_as_array
  #   recs = product_apps.all
  #   # if recs.has_many?
  #   #   recs
  #   # else
  #   #   [recs]
  #   # end
  # end
  
  
end
