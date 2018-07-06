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
#  is_multicolor         :boolean          default(FALSE)
#  avg_rating            :float            default(0.0), not null
#  price_cents           :integer          default(0), not null
#  cost_cents            :integer
#  product_reviews_count :integer
#  created_at            :datetime
#  updated_at            :datetime
#

require 'rails_helper'

RSpec.describe Product, :type => :model do
  describe '#is_multicolor' do
    it 'returns true when true' do
      p = FactoryBot.build :product, is_multicolor: true
      expect(p.is_multicolor?).to be true
    end 
    
  end
end
