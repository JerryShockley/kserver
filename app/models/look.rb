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

class Look < ActiveRecord::Base
  belongs_to :user
  has_many :look_reviews, dependent: :destroy, inverse_of: :look
  has_many :videos, as: :videoable
  has_many :images, as: :imageable
  has_one :face_map, dependent: :destroy, inverse_of: :look

  has_many :product_sets, dependent: :destroy
  
end
