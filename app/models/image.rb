# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  filename   :text
#  user_id    :integer
#  active     :boolean
#  file_size  :integer
#  width      :integer
#  height     :integer
#  created_at :datetime
#  updated_at :datetime
#

class Image < ActiveRecord::Base
  belongs_to :user
  has_many :imageusages
end
