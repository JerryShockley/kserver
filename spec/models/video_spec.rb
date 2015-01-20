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

require 'rails_helper'

RSpec.describe Video, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
