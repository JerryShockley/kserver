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

FactoryGirl.define do
  factory :face_map_step do
    number 1
    description { Faker::Lorem.sentences(Random.rand(1..3)).join(" ") }
    face_map nil
  end

end
