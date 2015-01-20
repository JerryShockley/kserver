# == Schema Information
#
# Table name: products
#
#  id             :integer          not null, primary key
#  sku            :text             not null
#  brand          :text
#  line           :text
#  name           :text
#  shade_name     :text
#  shade_code     :text
#  short_desc     :text
#  desc           :text
#  image_usage_id :integer
#  hex_color_val  :text
#  active         :boolean
#  price_cents    :integer          default(0), not null
#  cost_cents     :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe Product, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
