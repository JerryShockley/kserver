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

class FaceMap < ActiveRecord::Base
  has_many :face_map_steps
  belongs_to :look, inverse_of: :face_map
  belongs_to :image
  belongs_to :user
end
