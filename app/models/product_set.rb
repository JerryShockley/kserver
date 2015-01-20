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

class ProductSet < ActiveRecord::Base
  belongs_to :look
  belongs_to :user
  has_many :product_clusters
  
  def clusters_by_category(category)
    return product_clusters if category.blank?
    product_clusters.find_all { |pc| pc.category == category.to_s}
  end

  
  # def cluster_count(category=nil)
  #   if category.nil?
  #     product_clusters.count
  #   else
  #     product_clusters.by_category(category).count
  #   end
  # end
  
  #
  # def product_clusters_as_array(category=nil)
  #   recs=nil
  #   if category.nil?
  #     recs = product_clusters.all
  #   else
  #     recs = product_clusters.by_category(category)
  #   end
  #
  #   if recs.size > 1
  #     recs
  #   else
  #     [recs]
  #   end
  # end
  

end
