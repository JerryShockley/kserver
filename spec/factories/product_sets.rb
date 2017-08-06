# == Schema Information
#
# Table name: product_sets
#
#  id         :integer          not null, primary key
#  look_id    :integer          not null
#  skin_color :text             not null
#  user_id    :integer
#  created_at :datetime
#  updated_at :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl
require 'core_ext/string'

def create_cluster(product_set, evaluator, category, role, subrole=nil)
  product_set.product_clusters << create(:cluster_create_apps, category: category, role: role, user: evaluator.user,
                                         subrole: subrole, app_cnt: evaluator.app_cnt)  
end

# this one looks up existing products vs creating new
def create_seed_cluster(product_set, evaluator, category, role, subrole=nil)
  product_set.product_clusters << create(:product_cluster_with_product_apps, category: category, role: role, user: evaluator.user,
                                         subrole: subrole)  
end



def build_cluster(product_set, evaluator, category, role, subrole=nil)
  product_set.product_clusters << build_stubbed(:cluster_build_apps, category: category, role: role, user: evaluator.user, 
                                        subrole: subrole, app_cnt: evaluator.app_cnt)  

end


FactoryGirl.define do
  factory :product_set do
    look_id 1
    skin_color {Faker::Number.number(6)}
    user nil
    
    
    
    
    factory :product_set_create_clusters do

      transient do
        category_roles nil
        app_cnt 1
      end
    
      after(:create) do |product_set, evaluator|
        unless evaluator.category_roles.nil?
          evaluator.category_roles.each_key do |category|
            evaluator.category_roles[category].each do |role|
              if role.class == Array
                raise ArgumentError, "Invalid array size for role: #{role.to_s}" if role.size != 2
                create_cluster(product_set, evaluator, category, role[0], role[1])
              else
                create_cluster(product_set, evaluator, category, role)
              end
            end
          end
          byebug
          product_set.order_clusters unless product_set.look.nil? || product_set.look.face_map.nil?
          puts "hello"
          
        end
      end
    end      
    
    
    factory :product_set_build_clusters do

      transient do
        category_roles nil
        app_cnt 1
      end
    
      after(:stub) do |product_set, evaluator|
        unless evaluator.category_roles.nil?
          evaluator.category_roles.each_key do |category|
            evaluator.category_roles[category].each do |role|
              if role.class == Array
                raise ArgumentError, "Invalid array size for role: #{role.to_s}" if role.size != 2
                build_cluster(product_set, evaluator, category, role[0], role[1])
              else
                build_cluster(product_set, evaluator, category, role)
              end
            end
          end
        end
      end
    end      

    
    factory :product_set_with_clusters do

      transient do
        category_roles nil
        app_cnt 2
      end
    
      after(:create) do |product_set, evaluator|
        # cat_cnt = Random.rand(0..3)
        # evaluator.category_roles.keys
        evaluator.category_roles.each_key do |category|
          evaluator.category_roles[category].each do |role|
            if role.class == Array
              raise ArgumentError, "Invalid array size for role: #{role.to_s}" if role.size != 2
              create_seed_cluster(product_set, evaluator, category, role[0], role[1])
            else
              create_seed_cluster(product_set, evaluator, category, role)
            end
            
            
          end
        end
      end
      
    end
  end
end
