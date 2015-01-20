# == Schema Information
#
# Table name: images
#
#  id         :integer          not null, primary key
#  filename   :text
#  user_id    :integer
#  active     :boolean
#  file_size  :integer
#  width      :integer
#  height     :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :image, :class => 'Image' do
    filename "MyString"
    user nil
    active false
    file_size 1
    width 1
    height 1
  end
end
