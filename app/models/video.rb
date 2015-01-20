# == Schema Information
#
# Table name: videos
#
#  id         :integer          not null, primary key
#  name       :text
#  size       :integer
#  duration   :string
#  filename   :text
#  dimensions :text
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

class Video < ActiveRecord::Base
  belongs_to :user
  has_many :video_usages
end
