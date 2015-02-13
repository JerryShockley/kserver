# == Schema Information
#
# Table name: colors
#
#  id            :integer          not null, primary key
#  product_id    :integer
#  name          :text
#  code          :text
#  hex_color_val :text
#  state         :text
#  created_at    :datetime
#  updated_at    :datetime
#

require 'rails_helper'

RSpec.describe Color, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
