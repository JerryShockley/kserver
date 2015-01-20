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

require 'rails_helper'

RSpec.describe Profile, :type => :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
