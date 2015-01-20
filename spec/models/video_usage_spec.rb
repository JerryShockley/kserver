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

require 'rails_helper'

RSpec.describe VideoUsage, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
