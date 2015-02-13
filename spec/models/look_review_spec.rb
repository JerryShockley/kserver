# == Schema Information
#
# Table name: look_reviews
#
#  id          :integer          not null, primary key
#  title       :text
#  rating      :integer
#  recommended :boolean
#  use_again   :boolean
#  review      :text
#  look_id     :integer
#  user_id     :integer
#  state       :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe LookReview, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
