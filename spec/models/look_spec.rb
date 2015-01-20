# == Schema Information
#
# Table name: looks
#
#  id               :integer          not null, primary key
#  title            :text
#  short_desc       :text
#  desc             :text
#  usage_directions :text
#  user_id          :integer
#  active           :boolean
#  created_at       :datetime
#  updated_at       :datetime
#

require 'rails_helper'

RSpec.describe Look, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
