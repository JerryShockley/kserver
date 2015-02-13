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
#  state       :text
#  created_at  :datetime
#  updated_at  :datetime
#

class ProductReview < ActiveRecord::Base
  belongs_to :product, counter_cache: true, inverse_of: :product_reviews
  belongs_to :user  
end
