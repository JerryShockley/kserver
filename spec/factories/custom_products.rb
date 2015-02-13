# == Schema Information
#
# Table name: custom_products
#
#  id                    :integer          not null, primary key
#  custom_product_set_id :integer
#  product_app_id        :integer
#  created_at            :datetime
#  updated_at            :datetime
#

FactoryGirl.define do
  factory :custom_product do
    custom_product_set nil
product_app nil
  end

end
