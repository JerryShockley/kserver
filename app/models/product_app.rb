# == Schema Information
#
# Table name: product_apps
#
#  id         :integer          not null, primary key
#  role       :integer          not null
#  product_id :integer          not null
#  user_id    :integer
#  category   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

class ProductApp < ActiveRecord::Base
  belongs_to :product
  belongs_to :user
  has_many :product_recommendations, inverse_of: :product_app
  has_many :product_clusters, through: :product_recommendations
  
  has_many :custom_look_products, inverse_of: :product_app
  has_many :custom_looks, through: :custom_look_products
  
  
  def self.by_category(category)
    ProductApp.includes(:product).where("product_apps.category = ?", self.categories[category.to_s].to_s).order(:brand)
  end 

  
  enum category: [:cheeks, :eyes, :face, :lips]
  enum role: [:basic_shadow, :bb_cream, :blush, :bronzer, :concealer, :contour, :crease_shadow, :foundation, :gloss,
              :highlight_shadow, :liner_bottom, :liner_top, :lipstick, :mascara, :pencil, :powder, :primer]
  
  FACE_ROLES = %w(BB\ Cream Bronzer Concealer Contour Foundation Powder Primer )
  EYE_ROLES = %w(Basic\ Shadow Crease\ Shadow Highlight\ Shadow Liner\ Bottom Liner\ Top Mascara)
  LIP_ROLES = %w(Gloss Lipstick Pencil)
  CHEEK_ROLES = %w(Blush Contour)

end
