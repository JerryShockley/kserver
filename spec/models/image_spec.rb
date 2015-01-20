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

require 'rails_helper'

RSpec.describe Image, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
