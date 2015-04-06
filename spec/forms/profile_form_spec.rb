require File.expand_path(File.dirname(__FILE__) + '/../rails_helper')

require './app/models/profile'

# include FactoryGirl::Syntax::Methods

describe ProfileForm do
  
  describe "#initialize" do
    context 'called with no parameters' do
      pform = ProfileForm.new
      it 'initializes an empty ProfileForm' do
        expect(pform.email.blank?).to eq true
      end
    end
    # context 'called with a User instance' do
    #   user = build_stubbed :user
    #   pform = ProfileForm.new(user)
    #   it 'initializes all corresponding ProfileForm attributes' do
    #     pform.user_param_keys(false).each do |key|
    #       msg = "key == #{key}"
    #       expect(pform.send key).to eq(user[key]), msg
    #     end
    #   end
    # end
    # context 'called with a Profile instance' do
    #   profile = build_stubbed :profile
    #   pform = ProfileForm.new(profile)
    #   it 'initializes all corresponding ProfileForm attributes' do
    #     profile = build_stubbed :profile
    #     pform = ProfileForm.new(profile)
    #     pform.profile_param_keys.each do |key|
    #       expect(pform.send key).to eq(profile.send key)
    #     end
    #   end
    # end
  end
  
  
  # describe '#save' do
  #   context 'updating a valid object' do
  #     it 'saves the user instance' do
  #       profile = build_stubbed(:profile)
  #
  #
  #       # new_pf_params = attributes_for(:profile)
  #       # allow(Profile).to receive(:find_by).with(email: profile.email).and_return(profile)
  #       user = create(:user, email: profile.email, password: "foobar", first_name: profile.first_name,
  #                                   last_name: profile.last_name)
  #       pf = ProfileForm.new(user)
  #       pf_params = pf.unique_objects_attributes.merge(password: "foobar")
  #       pf.save(pf_params)
  #
  #     end
  #     it 'saves the profile instance' do
  #
  #     end
  #     it 'returns true' do
  #
  #     end
  #   end
  #   context 'with an invalid object' do
  #
  #   end
  # end
  

end

def profile_attribs_for_form(profile_obj)
  profile_obj.attributes.slice(:first_name, :last_name, :email, :street1, :street2, :city,
                               :state, :postal_code, :receive_emails, :source)
end

