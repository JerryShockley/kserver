# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#    Mayor.new(name: 'Emanuel', city: cities.first)

# Populating 1 User for each role

require 'factory_girl_rails'

class Seeds
  ROLES_HASH ||= {
            face: ProductApp::FACE_ROLES.map { |e| e.snakecase.to_sym},
            eyes: ProductApp::EYE_ROLES.map { |e| e.snakecase.to_sym},
            lips: ProductApp::LIP_ROLES.map { |e| e.snakecase.to_sym},
            cheek: ProductApp::CHEEK_ROLES.map { |e| e.snakecase.to_sym}
          }

  SIZE ||= {
            face: ProductApp::FACE_ROLES.size - 1,
            eyes: ProductApp::EYE_ROLES.size - 1,
            lips: ProductApp::LIP_ROLES.size - 1,
            cheek: ProductApp::CHEEK_ROLES.size - 1
          }

  CUSTOMER_COUNT = 100
  PRODUCT_COUNT = 100
  LOOK_COUNT = 10

  KLASSES = [User, Profile, Color, Product, ProductApp, ProductCluster, ProductRecommendation, Image, Video, 
             CustomProductSet, ProductReview, LookReview, Look, FaceMap, FaceMapStep]

  def seed_db
    build_production_accounts
      
    unless ENV[RAILS_ENV].trim.casecmp "production" 
      build_dev_accounts
      build_products
      build_looks

      KLASSES.each do |klass| 
       puts "--  Created #{klass.count} #{klass.name} record#{"s" if klass.count > 1} during reseeding"
      end
    end
  end
  

  def remove_records
    KLASSES.each do |klass| 
      puts "--  Removing #{klass.count} #{klass.name} record#{"s" if klass.count > 1} before reseeding"
      klass.destroy_all
    end 
  end

  
  
  
  private 


  def look_videos(look, user_id)
    video_hash = {  
                  face: "https://www.youtube.com/watch?v=DQpoOnI6wtM",
                  eyes: "https://www.youtube.com/watch?v=5bmA5Fxnalo",
                  lips: "https://www.youtube.com/watch?v=d8QjJetlQHQ", 
                  cheeks: "https://www.youtube.com/watch?v=REqphQgUNgA"
                 }

    video_hash.each do |category, link| 
      look.videos.create!(name: "#{category}", page: "look/show", group: "how_to", url: link, user_id: user_id)
    end
  end
  
  
  def look_images(look, user_id)
    categories = ["face", "eyes", "lips", "cheeks"]
 
    categories.each_with_index do |category, i| 
      look.images.create!(filename:  random_product_image_filename, dir: "product", user_id: user_id, name: "index_#{i}",
                          page: "look", template: "show", group: "how_to", role: category)
    end
    
    look.images.create!(filename: "look.jpg", dir: "look", user_id: user_id, name: "look_summary")
  end



  def random_product_image_filename
    ["img_1.png","img_2.png", "img_3.png", "img_4.jpg",  "img_5.jpg",  
          "img_6.jpg",  "img_7.jpg",  "img_8.jpg",  "img_9.jpg",  "img_10.jpg" ].shuffle.first
  end


  
  def logger
    Rails::logger
  end


  def build_looks 
    puts "\n***  Building Looks\n\n"
    
    usr_f = User.first.id
    usr_l = User.last.id
    10.times do
      user = User.find(Random.rand(usr_f..usr_l))
      look = FactoryGirl.create :look_with_product_sets, user: user
      look.product_sets.each {|ps| ps.order_clusters}
      look_videos(look, user)
      look_images(look, user)
    end
    
  end

  def build_products
    puts "\n***  Building Products"
    
    PRODUCT_COUNT.times { FactoryGirl.create :product_with_reviews}
  end


  def build_product_apps(cnt, usr_f, usr_l)
    products = build_products
    ROLES_HASH.keys.each do |category|
      ROLES_HASH[:category].each do |role|
        cnt.times do 
          create(:product_app, role: role, category: category, user_id: Random.rand(usr_f..usr_l))
        end
      end
    end
  
  end


  def display_records_to_be_removed

    KLASSES.each do |klass| 
      puts "--  Removing #{klass.count} #{klass.name} record#{"s" if klass.count > 1} before reseeding"
    end
  end

  def display_records_added
    KLASSES.each do |klass| 
      puts "--  Created #{Klass.count} #{klass.name} record#{"s" if klass.count > 1} during reseeding"
    end
  end

  def build_production_accounts
    puts "\n"
    usr = User.new
      usr.first_name = "Nina"
      usr.last_name = "Bhatti"
      usr.email = "nina@kokkoinc.com"
      usr.password = "foobar"
      usr.password_confirmation = "foobar"
      usr.sysadmin!
      usr.save!
      usr.create_profile!(first_name: usr.first_name, last_name: usr.last_name, email: usr.email)
      puts("Created #{usr.name}'s account")

    usr = User.new
      usr.first_name = "Scott"
      usr.last_name = "Trappe"
      usr.email = "scott@kokkoinc.com"
      usr.password = "foobar"
      usr.password_confirmation = "foobar"
      usr.sysadmin!
      usr.save!
      usr.create_profile!(first_name: usr.first_name, last_name: usr.last_name, email: usr.email)
      puts("Created #{usr.name}'s account")

    usr = User.new
    usr.first_name = "Jerry"
      usr.last_name = "Shockley"
      usr.email = "jerry@shockley.com"
      usr.password = "foobar"
      usr.password_confirmation = "foobar"
      usr.sysadmin!
      usr.save!
      usr.create_profile!(first_name: usr.first_name, last_name: usr.last_name, email: usr.email)
      puts("Created #{usr.name}'s account")
  end

  def build_dev_accounts

    usr = User.new
      usr.first_name = "Sysadmin"
      usr.last_name = "User"
      usr.email = "sysadmin@foo.com"
      usr.password = "foobar"
      usr.password_confirmation = "foobar"
      usr.sysadmin!
      usr.create_profile!(first_name: usr.first_name, last_name: usr.last_name, email: usr.email)
      puts("Created sysadmin user")
  
    usr = User.new
      usr.first_name = "Administrator"
      usr.last_name = "User"
      usr.email = "administrator@foo.com"
      usr.password = "foobar"
      usr.password_confirmation = "foobar"
      usr.administrator!
      usr.save!
      usr.create_profile!(first_name: usr.first_name, last_name: usr.last_name, email: usr.email)
      puts("Created administrator user")
  
    usr = User.new
      usr.first_name = "editor"
      usr.last_name = "User"
      usr.email = "editor@foo.com"
      usr.password = "foobar"
      usr.password_confirmation = "foobar"
      usr.editor!
      usr.save!
      usr.create_profile!(first_name: usr.first_name, last_name: usr.last_name, email: usr.email)
      puts("Created editor user")

    usr = User.new
      usr.first_name = "writer"
      usr.last_name = "User"
      usr.email = "writer@foo.com"
      usr.password = "foobar"
      usr.password_confirmation = "foobar"
      usr.writer!
      usr.save!
      usr.create_profile!(first_name: usr.first_name, last_name: usr.last_name, email: usr.email)
      puts("Created writer user")


    usr = User.new
      usr.first_name = "cust"
      usr.last_name = "User"
      usr.email = "cust@foo.com"
      usr.password = "foobar"
      usr.password_confirmation = "foobar"
      usr.save!
      usr.create_profile!(first_name: usr.first_name, last_name: usr.last_name, email: usr.email)
      puts("Created cust user")
      puts "\n***  Building Users"
  
      # Create linked users and profiles
      CUSTOMER_COUNT.times do
        FactoryGirl.create(:create_customer_profile)
      end
    
  end
  
end   

app = Seeds.new
app.remove_records
app.seed_db
