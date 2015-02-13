# == Schema Information
#
# Table name: images
#
#  id             :integer          not null, primary key
#  name           :text
#  filename       :text
#  dir            :text
#  page           :text
#  template       :text
#  group          :text
#  model          :text
#  role           :text
#  description    :text
#  file_type      :text
#  code           :text
#  user_id        :integer
#  state          :text
#  active         :text
#  file_size      :integer
#  width          :integer
#  height         :integer
#  imageable_id   :integer
#  imageable_type :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image do
    filename "MyString"
    user nil
    state "active"
    file_size 1
    width 1
    height 1
  end
end
