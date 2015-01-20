# == Schema Information
#
# Table name: video_usages
#
#  id         :integer          not null, primary key
#  page       :text
#  role       :text
#  video_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

class VideoUsage < ActiveRecord::Base
  belongs_to :video
  belongs_to :user

end
