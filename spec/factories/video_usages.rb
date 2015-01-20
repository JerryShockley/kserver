# == Schema Information
#
# Table name: video_usages
#
#  id         :integer          not null, primary key
#  page       :text
#  role       :text
#  video_id   :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :video_usage do
    page "my Page"
    role "My Role"
    video nil
  end
end
