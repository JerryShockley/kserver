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

class Color < ActiveRecord::Base
  belongs_to :product
  has_many :product_apps
end
