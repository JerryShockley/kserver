# == Schema Information
#
# Table name: look_images
#
#  id         :integer          not null, primary key
#  role       :string(255)
#  look_id    :integer
#  image_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class LookImage < ActiveRecord::Base
  belongs_to :look
  belongs_to :image
end
