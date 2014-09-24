require 'devise/registrations_controller'

require 'spec_helper'

# describe RegistrationsController do
#
#   describe "POST #users" # do
#
#     before :each do
#       request.env['devise.mapping'] = Devise.mappings[:user]
#     end
#
#     describe "creates a valid user" do
#
#       before :each do
#         post :create, user: {first_name: 'Joe', last_name: 'Long', email: 'joel@foo.edu',
#                             password: 'foobar', password_confirmation: 'foobar'}
#       end
#
#       it "with permitted params" do
#         pending "Have to figure out a way to test invalid fields and strong params"
#
#         # logger.debug "\n\n\n******    params = #{controller.params.inspect}\n\n\n"
#         # expect(controller.params.permitted?).to be_true
#         # controller.params[:user].keys do |var|
#         #   expect(controller.params.permitted?(var.to_sym)).to be_true
#         # end
#       end
#
#       it "returns the correct response code" do
#         expect(response.status).to eq(302)
#       end
#
#       it "redirects to the correct path" do
#         expect(response).to redirect_to(root_path)
#       end
#
#     end
#
#       describe "fails to create user" do
#
#         before :each do
#           post :create, user: {first_name: 'Joe', last_name: 'Long', email: 'joel@foo.edu',
#                                password: 'foobar', password_confirmation: 'foobar',
#                                created_at: Time.now}
#         end
#
#
#         it "without permitted params" do
#           skip "Have to figure out a way to test invalid fields and strong params"
#           # logger.debug "\n\n+++++++++++++++    testing failed stuff = #{controller.flash.inspect}\n\n\n"
#           # expect(controller.params.permitted?).to be_false
#           # expect(controller.params.permitted(:created_at)).to be_false
#         end
#
#         it "returns the correct response code" do
#           skip "Have to figure out a way to test invalid fields and strong params"
#           # expect(response.status).to eq(302)
#         end
#
#         it "redirects to the correct path" do
#           # logger.debug "\n\n\n++++++++++++++++++++++   Fails to create user\n\n #{response.inspect}"
#           skip "Have to figure out a way to test invalid fields and strong params"
#             # expect(response).to redirect_to(new_user_registration_path)
#         end
#
#       end
#     end
# end



# permitted = params.require(:person).permit(:name, :age)
# permitted            # => {"name"=>"Francesco", "age"=>22}
# permitted.class      # => ActionController::Parameters
# permitted.permitted? # => true
#
# Person.first.update!(permitted)
# => #<Person id: 1, name: "Francesco", age: 22, role: "user">