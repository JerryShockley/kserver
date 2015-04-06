# == Schema Information
#
# Table name: product_apps
#
#  id         :integer          not null, primary key
#  role       :string(255)      not null
#  subrole    :string(255)
#  product_id :integer          not null
#  user_id    :integer
#  color_id   :integer
#  category   :string(255)      not null
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe ProductApp, :type => :model do
  
  describe '#===' do
    
    
    context 'for multicolor products' do
      let(:p1) {build(:product_app_build_product, is_multicolor: true)}
      let(:p2) {build(:product_app_build_product, is_multicolor: true)}
      
      it 'return false when the product_apps are different with different product and the same color' do
        p1.color = p2.color
        expect(p1 === p2).to be false
      end
      
      it 'returns true when the product_apps are different with the same products and different colors' do
        p2.product = p1.product
        expect(p1 === p2).to be true
      end
      
      it 'returns true when the product_apps are the same with the same products and same colors' do
        expect(p1 === p1).to be true
      end
      
    end
    
    context 'for non-multicolor products' do
      let(:p1) {build(:product_app_build_product, is_multicolor: false)}
      let(:p2) {build(:product_app_build_product, is_multicolor: false)}
    
      it 'returns true when the product_apps are the same' do
        expect(p1 === p1).to be true
      end
    
      it 'returns true when the product_apps are different with the same products and colors' do
        p2.product = p1.product
        p2.color = p1.color
        expect(p1 === p2).to be true
      end
    
      it 'returns false when the product_apps are different with the same products and different colors' do
        p2.product = p1.product
        expect(p1 === p2).to be false
      end
    
      it 'returns false when the product_apps are different with the same colors and different products' do
        p2.color = p1.color
        expect(p1 === p2).to be false
      end
    
      it 'returns false when the product_apps are different with different colors and products' do
        expect(p1 === p2).to be false
      end
      
    end
    
  end
  
  # describe '#same_product?' do
  #   let(:p1) {build(:product_app)}
  #   let(:p2) {build(:product_app)}
  #
  #   it 'returns true when the product_apps are the same' do
  #     expect(p1.same_product?(p1)).to be true
  #   end
  #
  #   it 'returns true when the product_apps are different with the same products and colors' do
  #     p2.product = p1.product
  #     p2.color = p1.color
  #     expect(p1.same_product?(p2)).to be true
  #   end
  #
  #   it 'returns false when the product_apps are different with the same products and different colors' do
  #     p2.product = p1.product
  #     expect(p1.same_product?(p2)).to be false
  #   end
  #
  #   it 'returns false when the product_apps are different with the same colors and different products' do
  #     p2.color = p1.color
  #     expect(p1.same_product?(p2)).to be false
  #   end
  #
  #   it 'returns false when the product_apps are different with different colors and products' do
  #     expect(p1.same_product?(p2)).to be false
  #   end
  #
  # end

end
