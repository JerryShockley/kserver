# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :text             default(""), not null
#  encrypted_password     :text             default(""), not null
#  reset_password_token   :text
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :text
#  last_sign_in_ip        :text
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
    
    # describe "titleize_names" do
    #
    #   it "capitalizes first_name" do
    #     name_lcase = "janet"
    #     name_ucase = "Janet"
    #     user = build_stubbed :cust, first_name: name_lcase
    #     user.send :titleize_names
    #     expect(user.first_name).to match name_ucase
    #   end
    #
    #   it "capitalizes last_name" do
    #     name_lcase = "smith"
    #     name_ucase = "Smith"
    #     user = build_stubbed :cust, last_name: name_lcase
    #     user.send :titleize_names
    #     expect(user.last_name).to match name_ucase
    #   end
    #
    #   it "downcases email" do
    #     email_lcase = "janet_smith@abc.com"
    #     email_ucase = "Janet_Smith@AbC.Com"
    #     user = build_stubbed :cust, email: email_ucase
    #     user.send :titleize_names
    #     expect(user.email).to match email_lcase
    #   end
    #
    #    # it "is called before save" do
      #   user = User.new
      #   expect(user).to receive(:titleize_names)
      #   user.run_callbacks :save
      # end
    # end
    
  

    
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

