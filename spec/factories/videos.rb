# == Schema Information
#
# Table name: videos
#
#  id         :integer          not null, primary key
#  name       :text
#  size       :integer
#  duration   :string
#  filename   :text
#  dimensions :text
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :video, :class => 'Video' do
    name "MyString"
    size 1
    duration ""
    filename "MyString"
    dimensions "MyString"
    user nil
  end
end
