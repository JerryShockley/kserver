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

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image_usage do
    page "MyString"
    role "MyString"
    image nil
  end
end
