# == Schema Information
#
# Table name: custom_product_sets
#
#  id             :integer          not null, primary key
#  product_set_id :integer
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#

class CustomProductSet < ActiveRecord::Base
  
  belongs_to :product_set, inverse_of: :custom_product_set
  belongs_to :user
  has_many :custom_products, dependent: :destroy
  has_many :product_apps, through: :custom_products
  
end
