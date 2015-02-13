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

require 'rails_helper'

RSpec.describe CustomProductSet, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
