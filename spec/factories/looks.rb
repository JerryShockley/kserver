# == Schema Information
#
# Table name: looks
#
#  id                 :integer          not null, primary key
#  title              :text
#  code               :text
#  short_desc         :text
#  desc               :text
#  usage_directions   :text
#  avg_rating         :float            default(0.0), not null
#  user_id            :integer
#  state              :text
#  look_reviews_count :integer
#  created_at         :datetime
#  updated_at         :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

def random_look_code
  %w(A B C D E F)[Random.rand(0..3)] + Random.rand(100..999).to_s
end

def format_role_name(sym)
  sym.to_s.gsub("_", " ")
end


def role_hash_to_array(role_hash)
  result = []
  role_hash.each_key do |cat|
    role_hash[cat].each do |role|
      if role.class == Array
        raise ArgumentError, "Invalid array size for role: #{role.to_s}" if role.size != 2
        result << [[format_role_name(cat), format_role_name(role[0]), role[1]]]
      else
        result << [[format_role_name(cat), format_role_name(role)]]
      end
    end
  end
  result
end


FactoryGirl.define do
  sequence :utitle do |n|
    "Really Awesome Look ##{n}"
  end
end

FactoryGirl.define do
  factory :look do
    title {generate :utitle}
    short_desc {Faker::Lorem.words(Random.rand(5..13)).join(" ")}
    desc {Faker::Lorem.paragraphs(Random.rand(2..4)).join("\n\n")}
    usage_directions {Faker::Lorem.sentences(3).join("  ")}
    user nil
    state "active" 
    code {random_look_code}
    avg_rating {Random.rand(3.0..5.1).round(1)}
    look_reviews_count {Random.rand(1..500)}
    face_map nil
    
    transient do
      category_roles {{face: [:foundation, :primer, :powder, :concealer],
                        eyes: [:basic_shadow, :highlight_shadow, [:highlight_shadow, "1"], :liner_bottom, :liner_top, :concealer],
                        lips: [:gloss, :lipstick, :pencil],
                        cheeks: [:blush]}}
    end
      
    factory :look_with_product_sets do
      
      count = Random.rand(1..3)
    
      after(:create) do |look, evaluator|
        count.times do
            look.product_sets << create(:product_set_with_clusters, user_id: evaluator.user_id, category_roles: evaluator.category_roles)
        end
        look.face_map = FactoryGirl.create(:face_map, user_id: evaluator.user_id, look: look, roles_ary: role_hash_to_array(evaluator.category_roles))
        look.save!
      end
    end
  end
end
