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
  
  # Creates an array of product role arrays of the form [["category", "role", "optional subrole"]]. 
  # Each parameter in the face map steps will generate on product role array.
  
  def ordered_product_role_array
     val = face_map_steps.sort.map {|step| step.ordered_product_role_array}
     val = val.flatten(1)     
  end

end
