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
  has_many :product_clusters #, inverse_of: :product_set
  has_many :custom_product_sets
  

  def clusters_by_category(category)
    # self.order_clusters
    val = product_clusters.sort.find_all { |pc| pc.category == category.to_s}
    val.sort
  end
  
  def product_cluster(category, role, subrole=nil)
    product_clusters.find do |cluster| 
      cluster.has_role?(category, role, subrole)
    end
  end
  
  
  def selected_product_apps
    product_clusters.sort.map {|pc| pc.selected_product_app}
  end
  

  def unique_billable_product_apps(category=nil)
    apps = selected_product_apps.dup
    result = []
    count = apps.count
    # byebug
    1.upto(count) do
      a = apps.shift
      result << a unless result.find {|pa| pa.product === a.product }
    end
    category.nil? ? result : result.find_all {|app| app.category == category.to_s.to_sc}
  end

  
  def selected_product_app(category, role, subrole=nil)
    pc = product_cluster(category, role, subrole)
    pc.selected_product_app
  end

  
  def selected_product_app_markup_name(category, role, subrole=nil)
    selected_product_app(category, role, subrole).markup_product_name
  end

  
  # def roles_hash
  #   product_clusters.each_with_object({}) do |cluster, hash|
  #     hash[cluster.category] = cluster.map {|app| app.role}
  #   end
  # end
  
  
  def categories
    # self.order_clusters
    categories = product_clusters.sort.map {|cluster| cluster.category}
    categories.uniq
  end
  

  
  def has_cluster_by_role?(*role_ary)
    product_clusters.any? {|pc| pc.has_role?(*role_ary)}
  end

  # Orders clusters based on face map steps and groups by category
  
  def order_clusters
    use_ary = self.look.face_map.ordered_product_role_array 
    use_ary.each_with_index do |params, idx|  
      set_cluster_use_order(idx + 1, *params)
    end
  end
  
  
  private

  
  
  def set_cluster_use_order(idx, category, role, subrole=nil)
    pc = product_cluster(category, role, subrole)
    raise ArgumentError, "Cluster not found ('#{category}', '#{role}', '#{subrole}') while ordering clusters" if pc.nil?
    unless pc.use_order == idx
      pc = ProductCluster.find(pc.id)
      pc.update!(use_order: idx)
    end
  end


end
