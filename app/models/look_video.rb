# == Schema Information
#
# Table name: look_videos
#
#  id         :integer          not null, primary key
#  role       :string(255)
#  look_id    :integer
#  video_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class LookVideo < ActiveRecord::Base
  belongs_to :look
  belongs_to :video
end
