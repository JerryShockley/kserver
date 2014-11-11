# == Schema Information
#
# Table name: profiles
#
#  id             :integer          not null, primary key
#  first_name     :string(255)
#  last_name      :string(255)
#  email          :string(255)
#  street1        :string(255)
#  street2        :string(255)
#  city           :string(255)
#  state          :string(255)
#  postal_code    :string(255)
#  receive_emails :boolean          default(TRUE)
#  created_at     :datetime
#  updated_at     :datetime
#

class Profile < ActiveRecord::Base
 
 belongs_to :user, inverse_of: :profile
  


end
