# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  sku                   :text             not null
#  brand                 :text
#  line                  :text
#  name                  :text
#  code                  :text
#  short_desc            :text
#  desc                  :text
#  size                  :text
#  manufacturer_sku      :text
#  state                 :text
#  avg_rating            :float            default(0.0), not null
#  price_cents           :integer          default(0), not null
#  cost_cents            :integer
#  product_reviews_count :integer
#  created_at            :datetime
#  updated_at            :datetime
#

class Product < ActiveRecord::Base
  
  has_many :product_apps, inverse_of: :product
  has_many :product_reviews, dependent: :destroy, inverse_of: :product
  has_many :colors, dependent: :destroy, inverse_of: :product
  has_one :image, as: :imageable, dependent: :destroy
  
  monetize :price_cents # creates a price attr
  monetize :cost_cents  # creates a cost attr
  
  ratyrate_rateable 
end
