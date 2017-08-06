# == Schema Information
#
# Table name: product_sets
#
#  id         :integer          not null, primary key
#  look_id    :integer          not null
#  skin_color :text             not null
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe ProductSet, :type => :model do
  
  # describe '#unique_billable_product_apps' do
  #
  #   let(:pa1) {build_stubbed :product_app_build_product}
  #   let(:pa2) {build_stubbed :product_app_build_product}
  #   let(:pa3) {build_stubbed :product_app_build_product, is_multicolor: true}
  #   let(:pa4) {build_stubbed :product_app_build_product, is_multicolor: true}
  #
  #   let(:pad1) {build_stubbed :product_app_build_product, prod: pa1.product}
  #   let(:pad12) {build_stubbed :product_app_build_product, prod: pa1.product}
  #   let(:pad2) {build_stubbed :product_app_build_product, prod: pa2.product}
  #   let(:pad4) {build_stubbed :product_app_build_product, prod: pa4.product}
  #
  #
  #   context 'containing no duplicates' do
  #     let(:ps) {build_stubbed :product_set}
  #     subject(:result) {ps.unique_billable_product_apps}
  #
  #     it 'returns all product_apps' do
  #       allow(ps).to receive(:selected_product_apps).and_return([pa1, pa2, pa3, pa4])
  #       expect(result.count).to eq 4
  #     end
  #
  #
  #     it 'removes multicolor product_app with the same product and different colors' do
  #       allow(ps).to receive(:selected_product_apps).and_return([pa1, pa2, pa3, pa4, pad4])
  #       expect(result.count).to eq 4
  #     end
  #
  #
  #     it 'returns all product_apps' do
  #       allow(ps).to receive(:selected_product_apps).and_return([pa1, pa2, pa3, pa4])
  #       expect(result.count).to eq 4
  #     end
  #
  #
  #   end
  #
  #
  #   context 'containing 1 duplicate' do
  #     let(:ps) {build_stubbed :product_set}
  #     subject(:result) {ps.unique_billable_product_apps}
  #
  #     it 'excludes the duplicate from the returned values' do
  #       allow(ps).to receive(:selected_product_apps).and_return([pa1, pa2, pa3, pa4, pad1])
  #       expect(result.include?(pad1)).to be false
  #     end
  #
  #     it 'returns the correct number of product_apps' do
  #       allow(ps).to receive(:selected_product_apps).and_return([pa1, pa2, pa3, pa4, pad1])
  #       expect(result.count).to eq 4
  #     end
  #   end
  #
  #   context 'containing 2 duplicates' do
  #     let(:ps) {build_stubbed :product_set}
  #     subject(:result) {ps.unique_billable_product_apps}
  #
  #     it 'returns the correct number of product_apps' do
  #       allow(ps).to receive(:selected_product_apps).and_return([pa1, pa2, pa3, pa4, pad1, pad12])
  #       expect(result.count).to eq 4
  #     end
  #
  #     it 'excludes the duplicates from the returned values' do
  #       allow(ps).to receive(:selected_product_apps).and_return([pa1, pa2, pa3, pa4, pad1, pad12])
  #       expect(result.include?(pad1)).to be false
  #       expect(result.include?(pad12)).to be false
  #     end
  #   end
  #
  #
  #   context 'containing 2 sets of duplicates' do
  #     let(:ps) {build_stubbed :product_set}
  #     subject(:result) {ps.unique_billable_product_apps}
  #
  #     it 'returns the correct number of product_apps' do
  #       allow(ps).to receive(:selected_product_apps).and_return([pa1, pa2, pa3, pa4, pad1, pad2])
  #       expect(result.count).to eq 4
  #     end
  #
  #     it 'excludes the duplicates from the returned values' do
  #       allow(ps).to receive(:selected_product_apps).and_return([pa1, pa2, pa3, pa4, pad1, pad2])
  #       expect(result.include?(pad1)).to be false
  #       expect(result.include?(pad2)).to be false
  #     end
  #   end
  #
  #
  # end
  #
  #
  #
  #
  # describe '#selected_product_apps' do
  #   let(:role_hsh_simple) { {face: [:foundation, :concealer], eyes: [[:highlight_shadow, "1"]]} }
  #   let(:role_hsh_single) { {face: [:blush]} }
  #   let(:ps)  {create(:product_set_create_clusters, category_roles: role_hsh_simple, app_cnt: 3 )}
  #   let(:p1) {create(:product_set_create_clusters, category_roles: role_hsh_single, app_cnt: 3 )}
  #
  #   it 'returns 1 product app for each cluster when there are multiple clusters' do
  #     expect(ps.selected_product_apps.count).to eq 3
  #   end
  #
  #   it 'returns 1 product app  when there is a single cluster' do
  #     expect(p1.selected_product_apps.count).to eq 1
  #   end
  #
  #   it 'Each product_app returned has a product_recommendation.priority == 1' do
  #     ps.selected_product_apps.each do |pa|
  #       expect(pa.product_recommendations.first.priority).to eq 1
  #     end
  #   end
  # end
  #
  #
  #
  # describe '#has_cluster_by_role' do
  #   let(:role_hsh_simple) { {face: [:foundation], eyes: [:highlight_shadow]} }
  #   let(:ps)  {create(:product_set_create_clusters, category_roles: role_hsh_simple )}
  #   let(:role_ary_simple_eyes) {[:eyes, :highlight_shadow]}
  #   let(:role_ary_simple_face) {[:face, :foundation]}
  #
  #
  #   it 'returns true for a cluster with the same category and role' do
  #     # x = ps.product_clusters.first.role
  #     # byebug
  #     expect(ps.has_cluster_by_role?(*role_ary_simple_eyes)).to be true
  #     expect(ps.has_cluster_by_role?(*role_ary_simple_face)).to be true
  #   end
  #
  #   it 'returns false for a cluster with the wrong category or role' do
  #     expect(ps.has_cluster_by_role?(*[:lips, :lipstick])).to be false
  #   end
  # end
  #
  #
  #
  #
  #
  # describe '#clusters_by_category' do
  #   let(:role_hsh_simple) { {face: [:foundation, :concealer], eyes: [:highlight_shadow], lips: [:gloss]} }
  #   let(:ps)  {FactoryGirl.create(:product_set_create_clusters, category_roles: role_hsh_simple )}
  #
  #
  #   it 'returns multiple clusters for a valid category when there are multiple' do
  #     allow(ps).to receive(:order_clusters)
  #     expect(ps.clusters_by_category(:face).size).to eq 2
  #   end
  #
  #   it 'returns a single cluster for a valid category when there is only one' do
  #     allow(ps).to receive(:order_clusters)
  #     expect(ps.clusters_by_category(:eyes).size).to eq 1
  #   end
  #
  #   it 'returns an empty array for a category that does not exist' do
  #     allow(ps).to receive(:order_clusters)
  #     expect(ps.clusters_by_category(:cheeks).size).to eq 0
  #   end
  # end
  #
  #
  #
  #
  # describe '#product_cluster' do
  #   let(:role_hsh_simple) { {face: [:foundation, :concealer], eyes: [[:highlight_shadow, "1"], [:highlight_shadow, "2"]], lips: [:gloss]} }
  #   let(:ps)  {create(:product_set_create_clusters, category_roles: role_hsh_simple )}
  #
  #   it 'returns a product cluster with a matching category and role' do
  #     expect(ps.product_cluster(:lips, :gloss).role).to eq :gloss
  #   end
  #
  #   it 'returns a product cluster with a matching category, role and subrole' do
  #     expect(ps.product_cluster(:eyes, :highlight_shadow, "1").role).to eq :highlight_shadow
  #   end
  #
  #   it "returns nil when the specfied category and role don't exist" do
  #     expect(ps.product_cluster(:face, :highlight_shadow)).to be nil
  #   end
  #
  #   it "returns nil when the specfied category, role and subrole exist, but the subrole is not specified" do
  #     expect(ps.product_cluster(:eyes, :highlight_shadow)).to be nil
  #   end
  #
  # end



  describe '#categories' do
    let(:role_hsh_simple) { {face: [:foundation, :concealer], eyes: [:highlight_shadow], lips: [:gloss]} }
    let(:ps)  {create(:product_set_create_clusters, category_roles: role_hsh_simple )}

    it 'returns the correct categories' do
      allow(ps).to receive(:order_clusters)
      expect(ps.categories - ["face", "eyes", "lips"]).to eq []
    end

    it 'returns the categories in the correct order' do
 
      ps.product_cluster(:lips, :gloss).use_order = 1
      ps.product_cluster(:face, :concealer).use_order = 2
      ps.product_cluster(:face, :foundation).use_order = 3
      ps.product_cluster(:eyes, :highlight_shadow).use_order = 4
      allow(ps).to receive(:order_clusters)


      expect(ps.categories[0]).to eq "lips"
      expect(ps.categories[1]).to eq "face"
      expect(ps.categories[2]).to eq "eyes"
    end
  end


  # describe '#order_clusters' do
  #   let(:ary1) {[["face", "foundation"], ["face", "blush"], ["eyes", "basic shadow"], ["eyes", "highlight shadow"]]}
  #   let(:ary2) {[["eyes", "basic shadow"], ["eyes", "highlight shadow"], ["face", "foundation"], ["face", "blush"]]}
  #   let(:ary3) {[["face", "foundation"], ["face", "blush"], ["eyes", "basic shadow"], ["eyes", "highlight shadow"]]}
  #
  #   let(:hsh1) { {face: [:foundation, :blush], eyes: [:basic_shadow, :highlight_shadow]} }
  #   let(:ps) {create :product_set_create_clusters, category_roles: hsh1}
  #
  #
  #   it 'returns the correct order' do
  #     allow_any_instance_of(ProductSet).to receive_message_chain("look.face_map.ordered_product_role_array") {ary1}
  #     ps.order_clusters
  #     clusters = ps.product_clusters.sort
  #
  #     expect(clusters[0].role).to eq "foundation"
  #     expect(clusters[1].role).to eq "blush"
  #     expect(clusters[2].role).to eq "basic_shadow"
  #     expect(clusters[3].role).to eq "highlight_shadow"
  #
  #     allow_any_instance_of(ProductSet).to receive_message_chain("look.face_map.ordered_product_role_array") {ary2}
  #
  #     ps.order_clusters
  #     # byebug
  #     clusters = ps.product_clusters.sort
  #     expect(clusters[0].role).to eq "basic_shadow"
  #     expect(clusters[1].role).to eq "highlight_shadow"
  #     expect(clusters[2].role).to eq "foundation"
  #     expect(clusters[3].role).to eq "blush"
  #
  #   end
  # end
  

end
