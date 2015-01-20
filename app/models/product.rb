# == Schema Information
#
# Table name: products
#
#  id             :integer          not null, primary key
#  sku            :text             not null
#  brand          :text
#  line           :text
#  name           :text
#  shade_name     :text
#  shade_code     :text
#  short_desc     :text
#  desc           :text
#  image_usage_id :integer
#  hex_color_val  :text
#  active         :boolean
#  price_cents    :integer          default(0), not null
#  cost_cents     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class Product < ActiveRecord::Base
  
  has_many :product_apps
  has_many :product_reviews
  
  monetize :price_cents # creates a price attr
  monetize :cost_cents  # creates a cost attr
  

end
