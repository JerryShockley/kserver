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

FactoryGirl.define do
  factory :face_map do
    look nil
    image {FactoryGirl.create(:image, filename: "facemap.jpg", dir: "look", user_id: user_id, name: "facemap")}
    user_id nil
    face_map_steps []
    
    transient do
      roles_ary nil
    end
    
    after(:create) do |fm, evaluator|
      i = 1
      evaluator.roles_ary.each do |param_ary|
        fm.face_map_steps << create(:face_map_step, number: i, raw_markups: param_ary, face_map: fm)
        i += 1
      end
      fm.save!
    end
  end

end
