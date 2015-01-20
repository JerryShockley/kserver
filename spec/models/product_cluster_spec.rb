# == Schema Information
#
# Table name: product_clusters
#
#  id             :integer          not null, primary key
#  category       :text             not null
#  role           :text             not null
#  user_id        :integer
#  product_set_id :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe ProductCluster, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
