# == Schema Information
#
# Table name: product_reviews
#
#  id          :integer          not null, primary key
#  title       :text             not null
#  rating      :integer
#  recommended :boolean
#  use_again   :boolean
#  review      :text
#  product_id  :integer
#  user_id     :integer
#  active      :boolean
#  created_at  :datetime
#  updated_at  :datetime
#

class ProductReview < ActiveRecord::Base
  belongs_to :product
  belongs_to :user
  
  
end
