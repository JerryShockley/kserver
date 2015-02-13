# == Schema Information
#
# Table name: colors
#
#  id            :integer          not null, primary key
#  product_id    :integer
#  name          :text
#  code          :text
#  hex_color_val :text
#  state         :text
#  created_at    :datetime
#  updated_at    :datetime
#

FactoryGirl.define do
  factory :color do
    product_id 0
    
    name {["Beige", "Nude", "Porcelin Ivory", "Ivory", "Creamy Natural", "Sandy Beige", 
           "Medium Buff", "Pure Beige", "Sun Beige", "Turquiose Sea", "Earthly Taupe", 
           "Tuscan Lavendar", "Golden Halo", "Blue Blazes", "Pink Wink"][Random.new.rand(14)]}
           
    code {"n#{Faker::Number.number(3)}"}
    
    hex_color_val {["#F1C7A0", "#E6B48B", "#EDC196", "#DCA785", "#CE9F7A", "#CA9366", "#B67A4B", "#81471B", "#BBC9E1",
                    "#77569F", "#E2A86C", "#02363D", "#FFBFB6", "#EFB29B", "#AEBBD4", "#242F3F"][Random.new.rand(15)]}
    

    state "active"
  end

end
