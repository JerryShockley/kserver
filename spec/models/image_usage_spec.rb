# == Schema Information
#
# Table name: image_usages
#
#  id         :integer          not null, primary key
#  page       :text
#  role       :text
#  image_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe ImageUsage, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
