# == Schema Information
#
# Table name: videos
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
#  storage_site   :text
#  code           :text
#  size           :integer
#  duration       :time
#  url            :text
#  file_type      :text
#  user_id        :integer
#  status         :text
#  videoable_id   :integer
#  videoable_type :string(255)
#  created_at     :datetime
#  updated_at     :datetime
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
    state "active"
  end
end
