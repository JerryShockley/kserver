# == Schema Information
#
# Table name: products
#
#  id                    :integer          not null, primary key
#  sku                   :text             not null
#  brand                 :text
#  line                  :text
#  name                  :text
#  code                  :text
#  short_desc            :text
#  desc                  :text
#  size                  :text
#  manufacturer_sku      :text
#  state                 :text
#  avg_rating            :float            default(0.0), not null
#  price_cents           :integer          default(0), not null
#  cost_cents            :integer
#  product_reviews_count :integer
#  created_at            :datetime
#  updated_at            :datetime
#

require 'rails_helper'

RSpec.describe Product, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
