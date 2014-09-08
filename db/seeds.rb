# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#    Mayor.new(name: 'Emanuel', city: cities.first)

# Populating 1 User for each role

require 'faker'
require 'factory_girl'

puts "\n--  Removing #{User.count} User record#{"s" if User.count > 1} before reseeding"
User.destroy_all

usr = User.new
usr.first_name = "Nina"
  usr.last_name = "Bhatti"
  usr.email = "nina@kokkoinc.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"
  usr.sysadmin!
  puts("Created #{usr.name}'s account")

usr.first_name = "Scott"
  usr.last_name = "Trappe"
  usr.email = "scott@kokkoinc.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"
  usr.sysadmin!
  puts("Created #{usr.name}'s account")


usr.first_name = "Jerry"
  usr.last_name = "Shockley"
  usr.email = "jerry@shockley.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"
  usr.sysadmin!
  puts("Created #{usr.name}'s account")


usr = User.new
  usr.first_name = "Sysadmin"
  usr.last_name = "User"
  usr.email = "sysadmin@shockleynet.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"
  usr.sysadmin!
  puts("Created sysadmin user")
  
usr = User.new
  usr.first_name = "Administrator"
  usr.last_name = "User"
  usr.email = "administrator@shockleynet.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"
  usr.administrator!
  puts("Created administrator user")
  
usr = User.new
  usr.first_name = "editor"
  usr.last_name = "User"
  usr.email = "editor@shockleynet.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"
  usr.editor!
  puts("Created editor user")

usr = User.new
  usr.first_name = "writer"
  usr.last_name = "User"
  usr.email = "writer@shockleynet.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"
  usr.writer!
  puts("Created writer user")


usr = User.new
  usr.first_name = "cust"
  usr.last_name = "User"
  usr.email = "cust@shockleynet.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"

  puts("Created cust user")
  
  200.times do
    FactoryGirl::create(:user, { first_name: Faker::Name.first_name,
                    last_name:  Faker::Name.last_name
                  })
  end

puts "--  Created #{User.count} User record#{"s" if User.count > 1} During reseeding\n\n"
  
