# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)
#  last_name              :string(255)
#  role                   :integer
#

require 'rails_helper'

describe User do

  let(:sadmin) {build_stubbed :sysadmin}


    describe "validations" do
      it "is valid with a valid object" do
        expect(sadmin.valid?).to be_truthy
      end
      it "is invalid without email" do
        expect(valid_field?(:sysadmin, email: nil)).to be_falsey
      end

      it "is invalid with a duplicate email address" do
        usr = build(:sysadmin)
        usr.save!
        expect(valid_field?(:sysadmin, email: usr.email)).to be_falsey
        
      end
      
      it "is invalid without a first name" do 
        expect(valid_field?(:sysadmin, first_name: nil)).to be_falsey
      end
      
    end

    describe "name" do
      it "returns first_name followed by last_name separated by a space char" do
        fname = "Joe"
        lname = "Smith"
        name = "Joe Smith"
        usr = build_stubbed(:writer, {first_name: fname, last_name: lname})
        expect(usr.name).to match(name)
        
      end
    end
    
  

    
    describe "admin?" do
      it "returns true for administrator" do
        usr = build_stubbed(:administrator)
        expect(usr.admin?).to be_truthy
      end
  
      it "returns true for sysadmin" do
        expect(sadmin.admin?).to be_truthy
      end
  
      it "returns false for editor" do
        usr = build_stubbed(:editor)
        expect(usr.admin?).to be_falsey
      end
  
      it "returns false for writer" do
        usr = build_stubbed(:writer)
        expect(usr.admin?).to be_falsey
      end
  
      it "returns false for cust" do
        usr = build_stubbed(:cust)
        expect(usr.admin?).to be_falsey
      end
    end

  
    describe "staff?" do
      it "returns true for administrator" do
        usr = build_stubbed(:administrator)
        expect(usr.staff?).to be_truthy
      end
  
      it "returns true for sysadmin" do
        expect(sadmin.staff?).to be_truthy
      end
  
      it "returns true for editor" do
        usr = build_stubbed(:editor)
        expect(usr.staff?).to be_truthy
      end
  
      it "returns false for writer" do
        usr = build_stubbed(:writer)
        expect(usr.staff?).to be_truthy
      end
  
      it "returns false for cust" do
        usr = build_stubbed(:cust)
        expect(usr.staff?).to be_falsey
      end
    end
  

end

# Builds test class instance initializing a single col as specified in
# field_hash {:column_name => value}. Calls validate on the 
# instance and checks the susequent error hash for an error on the column 
# specified by field_hash returning true if this column is not in the errors
# and fals otherwise.

def valid_field?(class_sym, field_hash)
  usr = build_stubbed(class_sym, field_hash)
  usr.valid?
  !usr.errors.has_key?(field_hash.keys.first)
end

