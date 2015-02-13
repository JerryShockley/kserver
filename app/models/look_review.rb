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

class LookReview < ActiveRecord::Base
  belongs_to :look, counter_cache: true, inverse_of: :look_reviews
  belongs_to :user
end
