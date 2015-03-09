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
  end

end
