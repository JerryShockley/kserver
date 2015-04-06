# == Schema Information
#
# Table name: product_clusters
#
#  id             :integer          not null, primary key
#  category       :text             not null
#  role           :text             not null
#  subrole        :string(255)
#  use_order      :integer
#  user_id        :integer
#  product_set_id :integer          not null
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

describe ProductCluster, :type => :model do
  #TODO add test for fail condition
  describe '#selected_product_app' do
    let!(:pc)  {create(:cluster_create_apps, category: :face, role: :foundation, app_cnt: 0 )}
    let!(:pa1) {create(:product_app_create_product, category: pc.category, role: pc.role, subrole: pc.subrole)}
    let(:pa2) {create(:product_app_create_product, category: pc.category, role: pc.role, subrole: pc.subrole)}
    let!(:pa3) {create(:product_app_create_product, category: pc.category, role: pc.role, subrole: pc.subrole)}
    
    it 'returns the correct the product_app assciated with the product recommendation with priority == 1 ' do
      create(:product_recommendation, product_cluster: pc, product_app: pa2, priority: 2)
      create(:product_recommendation, product_cluster: pc, product_app: pa3, priority: 3)
      create(:product_recommendation, product_cluster: pc, product_app: pa1, priority: 1)
      
      expect(pc.selected_product_app).to eq(pa1) 
    end
  end
  
  
  
  describe '#<=>' do
    let(:pc) {build(:cluster_build_apps, use_order: 2)}
    let(:pc_same) {build(:cluster_build_apps, use_order: 2)}
    let(:pc_diff) {build(:cluster_build_apps, use_order: 3)}
    
    it 'returns 0 when to instances of product_clusters have the same value for use_order attribute' do
      expect(pc <=> pc_same).to eq 0
    end
    
    it 'return 1 when self is greater than parameter' do
      expect(pc_diff <=> pc).to eq 1
    end
    
    it 'return -1 when self is less than parameter' do
      expect(pc <=> pc_diff).to eq -1
    end
  end
  
  
  describe '#has_role?' do
    let(:pc)  {build(:cluster_build_apps, category: :face, role: :foundation)}
    let(:pc1) {build(:cluster_build_apps, category: :eyes, role: :basic_shadow)}
    let(:pcs) {build(:cluster_build_apps, category: :face, role: :foundation, subrole: "1")}

    
    it 'returns true when parameters are strings' do
      expect(pc.has_role?(*["face", "foundation"])).to be true      
    end
        
    it 'returns true when parameters are strings with spaces' do
      expect(pc1.has_role?(*["eyes", "basic shadow"])).to be true      
    end
    
    it 'returns true if the cluster has the specified category and role without a subrole' do
      expect(pc.has_role?(*[:face, :foundation])).to be true
    end

    it "returns false if the cluster has a category other than the specified category without a subrole" do
      expect(pc.has_role?(*[:face, :concealer])).to be false
    end

    it "returns false if the cluster has a role other than the specified role without a subrole" do
      expect(pc.has_role?(*[:eyes, :foundation])).to be false
    end


    it 'returns true if the cluster represents the specified role with a subrole' do
      expect(pcs.has_role?(*[:face, :foundation, "1"])).to be true
    end

    it "returns false if the cluster has a different subrole than was requested" do
      expect(pcs.has_role?(*[:face, :foundation, "2"])).to be false
    end
    
    it "returns false if the cluster doesn't have a subrole and one is specified" do
      expect(pc.has_role?(*[:face, :foundation, "1"])).to be false      
    end

    it "returns false if the cluster has a subrole and it isn't specified in the call" do
      expect(pcs.has_role?(*[:face, :foundation])).to be false
    end
    
  end

end
