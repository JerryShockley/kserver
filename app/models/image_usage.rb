# == Schema Information
#
# Table name: image_usages
#
#  id         :integer          not null, primary key
#  page       :text
#  role       :text
#  image_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class ImageUsage < ActiveRecord::Base
  belongs_to :image
  belongs_to :user
end
