# == Schema Information
#
# Table name: images
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
#  file_type      :text
#  code           :text
#  user_id        :integer
#  state          :text
#  active         :text
#  file_size      :integer
#  width          :integer
#  height         :integer
#  imageable_id   :integer
#  imageable_type :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe Image, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
