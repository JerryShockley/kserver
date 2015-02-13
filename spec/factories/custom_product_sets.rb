# == Schema Information
#
# Table name: custom_product_sets
#
#  id             :integer          not null, primary key
#  product_set_id :integer
#  user_id        :integer
#  created_at     :datetime
#  updated_at     :datetime
#

FactoryGirl.define do
  factory :custom_product_set do
    product_set nil
user nil
  end

end
