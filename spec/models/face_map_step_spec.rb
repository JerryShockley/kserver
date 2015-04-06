# == Schema Information
#
# Table name: face_map_steps
#
#  id          :integer          not null, primary key
#  number      :integer
#  description :text
#  face_map_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

describe FaceMapStep, :type => :model do
  
  describe "Ordered markup parameter list" do
    let(:multi_markup_str) {"Apply <eyes:highlight shadow:1> just under the eyebrow and the <eyes:basic shadow> to the rest of the eye"}
    let(:markup_str) {"Apply <eyes:highlight shadow: 1> just under the eyebrow."}
    let(:no_markup_str) {"A great string without markup"}

    let(:valid_multi_full) {[["eyes", "highlight shadow", "1"], ["eyes", "basic shadow"]]}
    let(:valid_markup) {[["eyes", "highlight shadow", "1"]]}
    let(:no_markup) {[]}
    
    # let(:full_markup_str) {"Apply <eyes:highlight shadow> just under the eyebrow and the <eyes:basic shadow> to the rest of the eye"}
    
    it "returns an array of arrays when multiple markups are used" do
      step = build_stubbed(:face_map_step, number: 1, description: multi_markup_str)
      expect(step.ordered_product_role_array).to eq(valid_multi_full)
    end
    
    it 'returns an array of arrays when only one markup is used' do
      step = build_stubbed(:face_map_step, number: 1, description: markup_str)
      expect(step.ordered_product_role_array).to eq(valid_markup)      
    end
    
    it 'returns an empty array when no markup is used' do
      step = build_stubbed(:face_map_step, number: 1, description: no_markup_str)
      expect(step.ordered_product_role_array).to eq(no_markup)      
    end
        
  end
  
  

  
  describe "#merge_products" do
    
    let(:plain_str) {"This is a plain string with no markup"}
    let(:markup_str) {"Apply <eyes:highlight shadow> just under the eyebrow"}
    let(:incorrect_markup_str) {"Apply <eyes:highlight1 shadow> just under the eyebrow"}
    let(:markup_spaces_str) {"Apply < eyes: highlight shadow > just under the eyebrow"}
    let(:markup_caps_str) {"Apply <  eyes:HigHlight sHadOw > just under the eyebrow"}
    let(:multi_markup_str) {"Apply <eyes:highlight shadow> just under the eyebrow and the <eyes:basic shadow> to the rest of the eye"}
    let(:multi_subrole_str) {"Apply <eyes:highlight shadow:foo bar> just under the eyebrow and the <eyes:basic shadow:goo> to the rest of the eye"}
    let(:multi_subrole_spaces_str) {"Apply <eyes:highlight   shadow  :foo   bar> just under the eyebrow and the <eyes:basic shadow:goo> to the rest of the eye"}
    
    let(:single_result) {"Apply <span class='mu-product-name'>Very Cool Product #1</span> just under the eyebrow"}
    let(:multi_result) {"Apply <span class='mu-product-name'>Very Cool Name</span> just under the eyebrow and the <span class='mu-product-name'>Another not so Bad Name</span> to the rest of the eye"}
    let(:incorrect_markup_str_result) {"Apply <span class='mu-product-name'>(<eyes:highlight1 shadow> => Product not found)</span> just under the eyebrow"}
    
    
    it "does nothing to a string without template markup" do
      step = build(:face_map_step, number: 1, description: plain_str)
      translator = double("translator")      
      allow(translator).to receive(:selected_product_app_markup_name).and_return(plain_str)
      expect(step.merge_products(translator)).to eq(plain_str)
    end
    
    it "replaces an instance of markup in the string with a product name" do
      step = build(:face_map_step, number: 1, description: markup_str)
      translator = double("translator")
      expect(translator).to receive(:selected_product_app_markup_name).and_return("Very Cool Product #1")
      expect(step.merge_products(translator)).to eq(single_result)
    end    
    
    it "leaves markup in place when translation fails." do
      step = build(:face_map_step, number: 1, description: incorrect_markup_str)
      translator = double("translator")
      expect(translator).to receive(:selected_product_app_markup_name).and_return(nil)
      expect(step.merge_products(translator)).to eq(incorrect_markup_str_result)
    end    


    it "replaces an instance of markup with caps in the string with a product name" do
      step = build(:face_map_step, number: 1, description: markup_caps_str)
      translator = double("translator")
      expect(translator).to receive(:selected_product_app_markup_name).and_return("Very Cool Product #1")
      expect(step.merge_products(translator)).to eq(single_result)
    end

    
    it "replaces an instance of markup with spaces in the string with a product name" do
      step = build(:face_map_step, number: 1, description: markup_spaces_str)
      translator = double("translator")
      expect(translator).to receive(:selected_product_app_markup_name).and_return("Very Cool Product #1")
      expect(step.merge_products(translator)).to eq(single_result)
    end

    
    it "replaces multiple instances of markup in the string with their respective product name" do
      step = build(:face_map_step, number: 1, description: multi_markup_str)
      d1 = NameData.new(category: "eyes", role: "highlight shadow", name: "Very Cool Name")
      d2 = NameData.new(category: "eyes", role: "basic shadow", name: "Another not so Bad Name")
      translator = Translator.new([d1, d2])
      expect(step.merge_products(translator)).to eq(multi_result)
    end

    
    it "replaces multiple instances of markup with subroles in the string with their respective product name" do
      step = build(:face_map_step, number: 1, description: multi_subrole_str)
      d1 = NameData.new(category: "eyes", role: "highlight shadow", subrole: "foo bar", name: "Very Cool Name")
      d2 = NameData.new(category: "eyes", role: "basic shadow", subrole: "goo", name: "Another not so Bad Name")
      translator = Translator.new([d1, d2])
      expect(step.merge_products(translator)).to eq(multi_result)
    end
    
    it "replaces multiple instances of markup with subroles and spaces in the string with their respective product name" do
      step = build(:face_map_step, number: 1, description: multi_subrole_spaces_str)
      d1 = NameData.new(category: "eyes", role: "highlight shadow", subrole: "foo bar", name: "Very Cool Name")
      d2 = NameData.new(category: "eyes", role: "basic shadow", subrole: "goo", name: "Another not so Bad Name")
      translator = Translator.new([d1, d2])
      expect(step.merge_products(translator)).to eq(multi_result)
    end
  end
  
  
  
end

# We use this for multiple calls to translator

class Translator
  attr_accessor :data
  
  def initialize(args)
    @data = args
  end
  

  def selected_product_app_markup_name(category, role, subrole=nil)
    x = data.find do |pa|
          pa.category == category && pa.role == role && (subrole.nil? ? true : pa.subrole == subrole )
        end
    x.name
  end
end

class NameData
  attr_accessor :category, :role, :subrole, :name
  
  def initialize(args)
    @category = args[:category]
    @role = args[:role]
    @subrole = args[:subrole]
    @name = args[:name]
  end
end
