# == Schema Information
#
# Table name: videos
#
#  id             :integer          not null, primary key
#  name           :text
#  filename       :text
#  dir            :text
#  page           :text
#  template       :text
#  group          :text
#  model          :text
#  role           :text
#  description    :text
#  storage_site   :text
#  code           :text
#  size           :integer
#  duration       :time
#  url            :text
#  file_type      :text
#  user_id        :integer
#  status         :text
#  videoable_id   :integer
#  videoable_type :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Video < ActiveRecord::Base
  belongs_to :user
  belongs_to :videoable, polymorphic: true  
  
  def file_path
    File.join(dir, filename)
  end
  
end
