# == Schema Information
#
# Table name: look_reviews
#
#  id          :integer          not null, primary key
#  title       :text
#  rating      :integer
#  recommended :boolean
#  use_again   :boolean
#  review      :text
#  look_id     :integer
#  user_id     :integer
#  state       :text
#  created_at  :datetime
#  updated_at  :datetime
#

FactoryBot.define do
  factory :look_review do
    title {Faker::Lorem.words(Random.rand(3..8)).join(" ")}
    rating {Random.rand(0..5)}
    recommended {[false, true, nil][Random.rand(2)]}
    use_again {[false, true, nil][Random.rand(2)]}
    review {Faker::Lorem.sentences(Random.rand(2..13)).join(".  ")}
    product_id 1
    user_id 3
    state "active"
  end

end
