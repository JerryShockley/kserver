# == Schema Information
#
# Table name: face_map_steps
#
#  id          :integer          not null, primary key
#  number      :integer
#  description :text
#  face_map_id :integer
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe FaceMapStep, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
