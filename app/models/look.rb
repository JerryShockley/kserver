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

class Look < ActiveRecord::Base
  belongs_to :user

  # has_many :image_usages, dependent: :destroy
  # has_many :videos_usages, dependent: :destroy

  has_many :product_sets, dependent: :destroy
  
end
