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

require 'rails_helper'

RSpec.describe CustomProduct, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
