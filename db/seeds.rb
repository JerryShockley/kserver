# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#    Mayor.new(name: 'Emanuel', city: cities.first)

# Populating 1 User for each role


if Rails.env.production?
  User.create!(first_name: "Jerry", last_name: "Shockley", password: Rails.application.secrets.password_root, 
                email: "jerry@kokkoinc.com", role: :sysadmin)
  User.create!(first_name: "Scott", last_name: "Trappe", password: Rails.application.secrets.password_root, 
                email: "scott@kokkoinc.com", role: :administrator)
  puts "\nSeeded database with #{User.count} User records\n\n"
else

  require 'factory_girl'

  def logger
      Rails::logger
  end

  puts "\n--  Removing #{User.count} User record#{"s" if User.count > 1} and #{Profile.count} Profile record#{"s" if Profile.count > 1}  before reseeding"
  User.destroy_all
  Profile.destroy_all

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

  puts "--  Created #{User.count} User record#{"s" if Profile.count > 1} and #{Profile.count} Profile record#{"s" if Profile.count > 1} during reseeding\n\n"
  
end