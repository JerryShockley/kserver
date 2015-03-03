# == Schema Informationrequire "product_app"

#
# Table name: product_apps
#
#  id         :integer          not null, primary key
#  role       :integer          not null
#  product_id :integer          not null
#  user_id    :integer
#  color_id   :integer
#  category   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class ProductApp < ActiveRecord::Base
  extend Enumerize
  
  belongs_to :product
  belongs_to :color
  belongs_to :user
  has_many :product_recommendations, inverse_of: :product_app
  has_many :product_clusters, through: :product_recommendations
  
  has_many :custom_products, inverse_of: :product_apps
  has_many :custom_product_sets, through: :custom_products
  
  
  # TODO implement role parameter in by_category
  def self.by_category(category, role)
    ProductApp.includes(product: :reviews).where("product_apps.category = ?", self.categories[category.to_s].to_s).order(:brand)
  end 

  
  enumerize :category, in: [:cheeks, :eyes, :face, :lips]
  enumerize :role, in: [:basic_shadow, :bb_cream, :blush, :bronzer, :concealer, :contour, :crease_shadow, :foundation, 
                        :gloss, :highlight_shadow, :liner_bottom, :liner_top, :lipstick, :mascara, :pencil, :powder, 
                        :primer]
  
  FACE_ROLES = %w(BB\ Cream Bronzer Concealer Contour Foundation Powder Primer )
  EYE_ROLES = %w(Basic\ Shadow Crease\ Shadow Highlight\ Shadow Liner\ Bottom Liner\ Top Mascara)
  LIP_ROLES = %w(Gloss Lipstick Pencil)
  CHEEK_ROLES = %w(Blush Contour)

end
