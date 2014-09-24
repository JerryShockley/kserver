require 'rails_helper'

=begin
  ***  Assumptions  ****
Currently, when we test for an admin we're invoking User#admin?. This returns returns true for
only :sysadmins and :administrators. We only test for a customer role for all non-admin roles as
there is no distinction currently in our UserPolicy between these roles. As we add these types of
distintions to UserPolicy we will need to add the necessary contexts and examples for each change.
It will also be necessary to reflect Uchanges in UserPolicy affecting the admin roles.   

=end


describe UserPolicy do
  subject { UserPolicy }

  # let(:admin) { create :sysadmin }
  
  let(:user) { create :cust }
  let(:other_user) {create :cust}
  

  context "when user is customer" do
    
    permissions :index? do

      it "denies access" do
        expect(subject).not_to permit(user)
      end
    end

    permissions :show? do

      it "prevents other users from seeing your profile" do
        expect(subject).not_to permit(user, other_user)
      end

      it "allows you to see your own profile" do
        expect(subject).to permit(user, user)
      end
    end

    permissions :update? do
      it "prevents updates of another's profile" do
        expect(subject).not_to permit(user, other_user)
      end

      it "allows you to edit your own profile" do
        expect(subject).to permit(user, user)
      end
    end

  permissions :destroy? do

    it "allows deleting your own profile" do
      expect(subject).to permit(user, user)
    end
    
    it "prevents deleting another's profile" do
      expect(subject).not_to permit(user, other_user)
    end
  end
end


  context "when user is an admin" do
    let(:admin) {create :sysadmin}

    permissions :index? do

      it "allows access" do
        expect(subject).to permit(admin)
      end
    end

    permissions :show? do

      it "they can see another's profile" do
        expect(subject).to permit(admin, user)
      end
      
      it "they can see their own profile" do
        expect(subject).to permit(admin, admin)
      end
      
    end

    permissions :update? do

      it "allows an admin to make updates to your own profile" do
        expect(subject).to permit(admin, admin)
      end

      it "allows an admin to make updates to another's profile" do
        expect(subject).to permit(admin, other_user)
      end
    end


    permissions :destroy? do

      it "allows an admin to delete any user" do
        expect(subject).to permit(admin, user)
      end

    end
  end
    
end
