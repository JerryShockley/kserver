# == Schema Information
#
# Table name: profiles
#
#  id             :integer          not null, primary key
#  first_name     :text
#  last_name      :text
#  email          :text
#  street1        :text
#  street2        :text
#  city           :text
#  state          :text
#  postal_code    :text
#  receive_emails :boolean          default(TRUE)
#  created_at     :datetime
#  updated_at     :datetime
#  source         :string(255)
#  user_id        :integer
#  skin_color     :string(255)
#  eye_color      :string(255)
#  hair_color     :string(255)
#  age            :string(255)
#  skin_type      :string(255)
#

class Profile < ActiveRecord::Base
 
 belongs_to :user, inverse_of: :profile
 has_one :avatar, class_name: Image, :as => :imageable, dependent: :destroy
 # has_one :avatar, class_name: "Image", through: image_usage
 

end
