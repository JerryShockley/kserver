class CustomLook < ActiveRecord::Base
  belongs_to :product_set
  belongs_to :user
  has_many :custom_look_products, dependent: :destroy, inverse_of: :custom_look
  has_many :product_apps, through: :custom_look_products
  
  
end