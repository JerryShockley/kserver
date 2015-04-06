# == Schema Information
#
# Table name: face_maps
#
#  id         :integer          not null, primary key
#  look_id    :integer
#  image_id   :integer
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

describe FaceMap, :type => :model do

  describe "ordered_markup_parameter_list" do
    let(:eye_markup_str) {"Apply <eyes:highlight  shadow> just under the eyebrow and the <eyes:basic shadow:1> to the " + 
                            "rest of the eye"}
    let(:face_markup_str) {"Gently add <face:foundation> to your beautiful face"}
    let(:lip_markup_str) {"Pucker up and add <lips:liPstick> generously left to right"}
    let(:cheek_markup_str) {"Apply <cheeks :blush> on the upper cheeks"}
    let(:no_markup_str) {"A really great string with no markup"}
    
    let(:valid_multi_step_result) {[["eyes", "highlight shadow"], ["eyes", "basic shadow", "1"], ["face", "foundation"],
                                    ["lips", "lipstick"], ["cheeks", "blush"]]}
    
    it "returns the correct ordered list with many markups" do
      s1 = build_stubbed(:face_map_step, number: 1, description: eye_markup_str)
      s2 = build_stubbed(:face_map_step, number: 2, description: face_markup_str)
      s3 = build_stubbed(:face_map_step, number: 3, description: lip_markup_str)
      s4 = build_stubbed(:face_map_step, number: 4, description: cheek_markup_str)
      fm = build_stubbed(:face_map, face_map_steps: [s3, s1, s4, s2])
    
      expect(fm.ordered_product_role_array).to eq(valid_multi_step_result)
    end
 
    
    it "returns the correct ordered list with a single markups" do
      s4 = build_stubbed(:face_map_step, number: 4, description: cheek_markup_str)
      fm = build_stubbed(:face_map, face_map_steps: [s4])
    
      expect(fm.ordered_product_role_array).to eq([["cheeks", "blush"]])
    end
    
    
    it "returns the correct ordered list with no markups" do
      s4 = build_stubbed(:face_map_step, number: 4, description: no_markup_str)
      fm = build_stubbed(:face_map, face_map_steps: [s4])
    
      expect(fm.ordered_product_role_array).to eq([])
    end
    
    
    
  end
  
  
end
