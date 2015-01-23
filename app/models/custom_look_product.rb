class CustomLookProduct < ActiveRecord::Base
  belongs_to :custom_look, inverse_of: :custom_look_products
  belongs_to :product_app, inverse_of: :custom_look_products


end
