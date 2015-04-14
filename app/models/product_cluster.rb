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

class ProductCluster < ActiveRecord::Base
  include ProductEnumerations
  include Comparable
  
  belongs_to :user
  belongs_to :product_set #, inverse_of: :product_cluster
  has_many :product_recommendations, dependent: :destroy, inverse_of: :product_cluster
  has_many :product_apps, :through => :product_recommendations

  accepts_nested_attributes_for :product_recommendations
    
  
  
  def selected_product_app
    # TODO check for multiple priority #1 recommendations
    product_recommendations.where( priority: 1).first.product_app
  end

  

  # def reorder_product_app(product_app, priority=1)
  #   if priority < 1 || priority > product_apps.size
  #     raise ArgumentError, "Argument 'priority' is out of valid range 1..#{product_apps.size}: #{priority}", caller
  #   end
  #
  #   product_recommendations.sort
  # end
  
  def has_role?(category, role, subrole=nil)
    ret = self.category == format_param(category) && self.role == format_param(role) && 
          ((subrole.blank? && self.subrole.blank?) ? true : self.subrole == format_param(subrole) )
  end


  def <=>(other)
  self.use_order <=> other.use_order
  end
  
  
  
  
  def sorted_products
    product_recommendations.sort.map {|pr| pr.product_app.product}
  end
  
  
  private
  
  
  def format_param(param)
    if param.blank? || param =~ /^\d.*/
      param
    else
      param.class == Symbol ? param : param.to_sc
    end
  end

  
  
end
