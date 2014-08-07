describe User do

  before(:each) { @user = create(:sysadmin)}

  # subject { @user }

    describe "#email" do
    end

    describe "validations" do
      it "is valid with a valid object" do
        expect(build(:sysadmin).valid?).to be_truthy
      end
      it "is invalid without email" do
        expect(valid_field?(:sysadmin, email: nil)).to be_falsey
      end

      it "is invalid with a duplicate email address" do
        usr = build(:sysadmin)
        usr.save
        expect(valid_field?(:sysadmin, email: usr.email)).to be_falsey
        
      end
      
      it "is invalid without a first name" do 
        expect(valid_field?(:sysadmin, first_name: nil)).to be_falsey
      end
      
    end
  
    describe "#admin? method" do
      it "returns true for administrator" do
        usr = create(:administrator)
        expect(usr.admin?).to be_truthy
      end
  
      it "returns true for sysadmin" do
        expect(@user.admin?).to be_truthy
      end
  
      it "returns false for teacher" do
        usr = create(:teacher)
        expect(usr.admin?).to be_falsey
      end
  
      it "returns false for Parent" do
        usr = create(:parent)
        expect(usr.admin?).to be_falsey
      end
  
      it "returns false for Student" do
        usr = create(:student)
        expect(usr.admin?).to be_falsey
      end
    end

  
    describe "#faculty? method" do
      it "returns true for administrator" do
        usr = create(:administrator)
        expect(usr.faculty?).to be_truthy
      end
  
      it "returns true for sysadmin" do
        expect(@user.faculty?).to be_truthy
      end
  
      it "returns true for teacher" do
        usr = create(:teacher)
        expect(usr.faculty?).to be_truthy
      end
  
      it "returns false for Parent" do
        usr = create(:parent)
        expect(usr.faculty?).to be_falsey
      end
  
      it "returns false for Student" do
        usr = create(:student)
        expect(usr.faculty?).to be_falsey
      end
    end
  

end

# Builds test class instance initializing a single col as specified in
# field_hash {:column_name => value}. Calls validate on the 
# instance and checks the susequent error hash for an error on the column 
# specified by field_hash returning true if this column is not in the errors
# and fals otherwise.

def valid_field?(class_sym, field_hash)
  usr = build(class_sym, field_hash)
  usr.valid?
  !usr.errors.has_key?(field_hash.keys.first)
end

