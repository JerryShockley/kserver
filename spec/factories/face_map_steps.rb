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

def build_markup_str(markup_ary)
  markup_ary.join(":").insert(0,"<") << ">"
end


FactoryGirl.define do
  factory :face_map_step do
    number 1
    description nil 
    face_map nil
    
    transient do
      raw_markups []
    end
    
    after :create do |fm_step, evaluator|
      ary = []
      evaluator.raw_markups.each_with_object("") do |raw_markup, str|
        ary << Faker::Lorem.sentence.scan(/\w+/).insert(Random.rand(2..4), build_markup_str(raw_markup))
      end
      fm_step.description = ary.join("  ")
      fm_step.save!
    end
  end

end
