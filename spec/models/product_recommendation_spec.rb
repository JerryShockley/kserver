# == Schema Information
#
# Table name: product_recommendations
#
#  id                 :integer          not null, primary key
#  product_cluster_id :integer          not null
#  product_app_id     :integer          not null
#  created_at         :datetime
#  updated_at         :datetime
#

require 'rails_helper'

RSpec.describe ProductRecommendation, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
