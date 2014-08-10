# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#    Mayor.new(name: 'Emanuel', city: cities.first)

# Populating 1 User for each role

puts "\n--  Removing #{User.count} User record#{"s" if User.count > 1} before reseeding"
User.destroy_all
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
  usr.first_name = "Teacher"
  usr.last_name = "User"
  usr.email = "teacher@shockleynet.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"
  usr.teacher!
  puts("Created teacher user")

usr = User.new
  usr.first_name = "Parent"
  usr.last_name = "User"
  usr.email = "parent@shockleynet.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"
  usr.parent1!
  puts("Created parent user")


usr = User.new
  usr.first_name = "Student"
  usr.last_name = "User"
  usr.email = "student@shockleynet.com"
  usr.password = "foobar"
  usr.password_confirmation = "foobar"
  usr.student!
  puts("Created student user")

puts "--  Created #{User.count} User record#{"s" if User.count > 1} During reseeding\n\n"
  
