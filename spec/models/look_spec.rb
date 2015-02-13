# == Schema Information
#
# Table name: looks
#
#  id                 :integer          not null, primary key
#  title              :text
#  code               :text
#  short_desc         :text
#  desc               :text
#  usage_directions   :text
#  avg_rating         :float            default(0.0), not null
#  user_id            :integer
#  state              :text
#  look_reviews_count :integer
#  created_at         :datetime
#  updated_at         :datetime
#

require 'rails_helper'

RSpec.describe Look, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
