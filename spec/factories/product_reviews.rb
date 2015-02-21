# == Schema Information
#
# Table name: product_reviews
#
#  id          :integer          not null, primary key
#  title       :text             not null
#  rating      :integer
#  recommended :boolean
#  use_again   :boolean
#  review      :text
#  product_id  :integer
#  user_id     :integer
#  state       :text
#  created_at  :datetime
#  updated_at  :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

STAR_IMG ||= Image.where("filename = ?", 'review_star.png')


def random_user
  # byebug
  id = Random.rand(User.first.id..User.last.id)
  User.find(id)
end

 
FactoryGirl.define do
  factory :product_review do
    title {Faker::Lorem.words(Random.rand(3..8)).join(" ")}
    rating {Random.rand(1..5)}
    recommended {[false, true, nil][Random.rand(2)]}
    use_again {[false, true, nil][Random.rand(2)]}
    review {Faker::Lorem.sentences(Random.rand(2..13)).join(".  ")}
    product_id 1
    user {random_user}
    state "active"
    
    # after(:create) do |product_review, evaluator|
    #   begin
    #     product_review.product.rate Random.rand(0..5), evaluator.user
    #   rescue Exception => e
    #     puts e.message
    #     puts e.backtrace.inspect
    #     puts "evaluator is nil!\n\n" if evaluator.nil?
    #     puts "evaluator.product is nil!\n\n" if evaluator.product.nil?
    #     puts "evaluator.user is nil!\n\n" if evaluator.user.nil?
    #     puts "prod_review = #{product_review.inspect}\n\nevaluator.product = #{evaluator.product.inspect}\n\nevaluator.user = #{evaluator.user.inspect}"
    #   end
    # end
    
  end
end
