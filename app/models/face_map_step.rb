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

class FaceMapStep < ActiveRecord::Base
  belongs_to :face_map
  

  def <=>(other)
  self.number <=> other.number
  end
  
end
