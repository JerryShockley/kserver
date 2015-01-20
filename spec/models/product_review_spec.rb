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

require 'rails_helper'

RSpec.describe ProductReview, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
