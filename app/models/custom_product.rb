# == Schema Information
#
# Table name: custom_products
#
#  id                    :integer          not null, primary key
#  custom_product_set_id :integer
#  product_app_id        :integer
#  created_at            :datetime
#  updated_at            :datetime
#

class CustomProduct < ActiveRecord::Base
  belongs_to :custom_product_set, inverse_of: :custom_product
  belongs_to :product_app, inverse_of: :custom_product
end
