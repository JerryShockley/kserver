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
  
  # TODO change algorithm to use product_recommendations instead of taking first
  def default_product_app
    product_apps.first
  end

   def reorder_product_app(product_app, priority=1)
    if priority < 1 || priority > product_apps.size
      raise ArgumentError, "Argument 'priority' is out of valid range 1..#{product_apps.size}: #{priority}", caller
    end
    
    product_recommendations.sort
  end
  
  def sorted_products
    product_recommendations.sort.map {|pr| pr.product_app.product}
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
  
  
  def sorted_products
    product_recommendations.sort.map {|pr| pr.product_app.product}
  end
  

  
  
end
