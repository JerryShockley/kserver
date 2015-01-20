# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#    Mayor.new(name: 'Emanuel', city: cities.first)

# Populating 1 User for each role



def build_products 
  10.times do
    FactoryGirl.create :look_with_product_sets
  end
    
end

def remove_products
  Product.destroy_all
  ProductApp.destroy_all
  ProductCluster.destroy_all
  
  ProductRecommendation.destroy_all
  ImageUsage.destroy_all
  Image.destroy_all
  VideoUsage.destroy_all
  Video.destroy_all
  ProductReview.destroy_all
  ProductSet.destroy_all
  Look.destroy_all
end



if Rails.env.production?
  unless User.where email: "jerry@kokkoinc.com"
    User.create!(first_name: "Jerry", last_name: "Shockley", password: Rails.application.secrets.password_root, 
                email: "jerry@kokkoinc.com", role: :sysadmin)
    puts "\nSeeded database with Jerry Shockley User records\n\n"
  end
  unless User.where email: "scott@kokkoinc.com"
    User.create!(first_name: "Scott", last_name: "Trappe", password: Rails.application.secrets.password_root, 
                email: "scott@kokkoinc.com", role: :administrator)
    puts "\nSeeded database with Scott Trappe User records\n\n"

  end

  remove_products
  build_products

  puts "--  Created #{Product.count} Product record#{"s" if Product.count > 1} during reseeding\n\n"
  
else

  require 'factory_girl'

  def logger
      Rails::logger
  end

  puts "\n--  Removing #{User.count} User record#{"s" if User.count > 1}"
  puts "--  Removing #{Profile.count} Profile record#{"s" if Profile.count > 1}  before reseeding"
  puts "--  Removing #{Look.count} Look record#{"s" if Look.count > 1} before reseeding"
  puts "--  Removing #{ProductSet.count} ProductSet record#{"s" if ProductSet.count > 1} before reseeding"
  puts "--  Removing #{ProductCluster.count} ProductCluster record#{"s" if ProductCluster.count > 1} before reseeding"
  puts "--  Removing #{ProductRecommendation.count} ProductRecommendation record#{"s" if ProductRecommendation.count > 1} before reseeding"
  puts "--  Removing #{Product.count} Product record#{"s" if Product.count > 1} before reseeding"
  puts "--  Removing #{ProductApp.count} ProductApp record#{"s" if ProductApp.count > 1} before reseeding"
  puts "--  Removing #{ProductReview.count} ProductReview record#{"s" if ProductReview.count > 1} before reseeding"
  

  User.destroy_all
  Profile.destroy_all
  remove_products
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
  
  
  
    # Create linked users and profiles
    200.times do
     FactoryGirl.create(:create_customer_profile)
    end

    puts "\n--  Created #{User.count} User record#{"s" if User.count > 1}"
    puts "--  Created #{Profile.count} Profile record#{"s" if Profile.count > 1} during reseeding"


    build_products
    
    puts "--  Created #{Look.count} Look record#{"s" if Look.count > 1} during reseeding"
    puts "--  Created #{ProductSet.count} ProductSet record#{"s" if ProductSet.count > 1} during reseeding"
    puts "--  Created #{ProductCluster.count} ProductCluster record#{"s" if ProductCluster.count > 1} during reseeding"
    puts "--  Created #{ProductRecommendation.count} ProductRecommendation record#{"s" if ProductRecommendation.count > 1} during reseeding"
    puts "--  Created #{Product.count} Product record#{"s" if Product.count > 1} during reseeding"
    puts "--  Created #{ProductApp.count} ProductApp record#{"s" if ProductApp.count > 1} during reseeding"
    puts "--  Created #{ProductReview.count} ProductReview record#{"s" if ProductReview.count > 1} during reseeding"
  
end
