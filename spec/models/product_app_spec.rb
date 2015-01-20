# == Schema Information
#
# Table name: product_apps
#
#  id         :integer          not null, primary key
#  role       :integer          not null
#  product_id :integer          not null
#  user_id    :integer
#  category   :integer          not null
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe ProductApp, :type => :model do
  let(:sadmin) {build_stubbed :product_app}
  
  it "a simple test" do
    expect(sadmin).to_not_be nil 
  end
  

end
