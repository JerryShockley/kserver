require 'pundit'

class Devise::RegistrationsController < DeviseController
  include PunditHelper
  prepend_before_filter :require_no_authentication, only: [ :new, :create, :cancel ]
  # prepend_before_filter :authenticate_scope!, only: [:edit, :update, :destroy]
  after_action :verify_authorized, except: [:new, :create, :cancel]
  


  # TODO Improve table behavior
  def index
    authorize User
    # save last search params in session. We only save blank search params if 
    # referrer is index. Note no other referrers would give us non-blank search params.
    save_search_params(session, params) if referrer_is_index?(params)
      
    @search_params = retrieve_search_params(session, params)
    @search = User.search(@search_params)
    @record_count ||= @search.result(distinct: true).count
    @users = @search.result(distinct: true).page(params[:page])
    @search.build_condition if @search.conditions.empty?
    @search.build_sort if @search.sorts.empty?
    
    respond_to do |format|
      format.html  
      format.js 
    end
  end
  

  def show
    id = params[:id] ? params[:id] : current_user.id
    @profile_form = ProfileForm.find(id)
    self.resource = @profile_form.user
    authorize @profile_form.user
  end
  


  # GET /resource/sign_up
  def new
    # build_resource({})
    @profile_form = ProfileForm.new
    @validatable = devise_mapping.validatable?
    if @validatable
      @minimum_password_length = resource_class.password_length.min
    end
    # respond_with self.resource
   respond_with @profile_form
    
  end

  # POST /resource
  def create
    build_resource(sign_up_params)
    @profile_form ||= ProfileForm.new(resource)
    # resource_saved = resource.save
    resource_saved = @profile_form.save params[:profile_form]
    yield resource if block_given?
    if resource_saved
      if resource.active_for_authentication?
        # Modification: added customized flash response with user name
        set_flash_message :notice, :signed_up, {name: resource.first_name }  if is_flashing_format?
        # set_flash_message :notice, :signed_up if is_flashing_format?
        sign_up(resource_name, resource)
        respond_with resource, location: after_sign_up_path_for(resource)
      else
        set_flash_message :notice, :"signed_up_but_#{resource.inactive_message}" if is_flashing_format?
        expire_data_after_sign_in!
        respond_with resource, location: after_inactive_sign_up_path_for(resource)
      end
    else
      clean_up_passwords resource
      @validatable = devise_mapping.validatable?
      if @validatable
        @minimum_password_length = resource_class.password_length.min
      end
      # render resource
      flash[:alert] = failed_save_msg(@profile_form)
      render :new
    end
  end

  # GET /resource/edit
 
 def edit
    # Modification: Lookup user for authentication. Use current_user if no user :id specified. 
    # This occurs because we have two routes to this action (devise: assumes current user and 
    # ours: passes an id)
    id = params[:id] ? params[:id] : current_user.id
    @profile_form = ProfileForm.find(id)  #ProfileForm.new(User.find(id))
    self.resource = @profile_form.user
    authorize @profile_form.user
    
  end

  # PUT /resource
  # We need to use a copy of the resource because we don't want to change
  # the current user in place.
  def update
    
    id = params[:id] ? params[:id] : current_user.id
    self.resource = resource_class.to_adapter.get!(id)
    @profile_form = ProfileForm.new(resource)
    # @current_user = current_user
    authorize self.resource                               
    prev_unconfirmed_email = resource.unconfirmed_email if resource.respond_to?(:unconfirmed_email)
    # if params[:password].blank
    # remove_password_params_if_blank_password
    # resource_updated = resource.update_attributes(user_params)
    resource_updated = @profile_form.save(params[:profile_form])
    # yield resource if block_given?
    if resource_updated
      if is_flashing_format?
        flash_key = update_needs_confirmation?(resource, prev_unconfirmed_email) ?
          :update_needs_confirmation : :updated
        set_flash_message :notice, flash_key
      end
      if resource.id == current_user.id
        sign_in resource_name, resource, bypass: true
        # respond_with resource, location: after_update_path_for(resource) 
        redirect_to root_path
      else  
        sign_in :user, current_user, bypass: true
        # redirect_to users_path
        redirect_to root_path
      end
    else
      clean_up_passwords resource
      flash[:alert] = failed_save_msg(@profile_form)
      render :edit
    end
  end
    

  # DELETE /resource
  def destroy
    id = params[:id] ? params[:id] : current_user.id
    self.resource = resource_class.to_adapter.get!(id)
    authorize self.resource
    self.resource.destroy
    Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name) if id == current_user.id
    set_flash_message :notice, :destroyed, { name: resource.name, email: resource.email} if is_flashing_format?
    yield resource if block_given?
    #FIXME fix this render to handle both cases.
    redirect_to users_path
  end

  # GET /resource/cancel
  # Forces the session data which is usually expired after sign
  # in to be expired now. This is useful if the user wants to
  # cancel oauth signing in/up in the middle of the process,
  # removing all OAuth session data.
  def cancel
    expire_data_after_sign_in!
    redirect_to new_registration_path(resource_name)
  end

  protected

  def update_needs_confirmation?(resource, previous)
    resource.respond_to?(:pending_reconfirmation?) &&
      resource.pending_reconfirmation? &&
      previous != resource.unconfirmed_email
  end

  # By default we want to require a password checks on update.
  # You can overwrite this method in your own RegistrationsController.
  def update_resource(resource, params)
    resource.update_with_password(params)
  end

  # Build a devise resource passing in the session. Useful to move
  # temporary session data to the newly created user.
  def build_resource(hash=nil)
    self.resource = resource_class.new_with_session(hash || {}, session)
  end

  # Signs in a user on sign up. You can overwrite this method in your own
  # RegistrationsController.
  def sign_up(resource_name, resource)
    sign_in(resource_name, resource)
  end

  # The path used after sign up. You need to overwrite this method
  # in your own RegistrationsController.
  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  # The path used after sign up for inactive accounts. You need to overwrite
  # this method in your own RegistrationsController.
  def after_inactive_sign_up_path_for(resource)
    scope = Devise::Mapping.find_scope!(resource)
    router_name = Devise.mappings[scope].router_name
    context = router_name ? send(router_name) : self
    context.respond_to?(:root_path) ? context.root_path : "/"
  end

  # The default url to be used after updating a resource. You need to overwrite
  # this method in your own RegistrationsController.
  def after_update_path_for(resource)
    signed_in_root_path(resource)
  end

  # Authenticates the current scope and gets the current resource from the session.
  def authenticate_scope!
    send(:"authenticate_#{resource_name}!", force: true)
    self.resource = send(:"current_#{resource_name}")
  end

  def sign_up_params
    devise_parameter_sanitizer.sanitize(:sign_up)
  end

  def account_update_params
    devise_parameter_sanitizer.sanitize(:account_update)
  end
  
  
  private
  
    def referrer_is_index?(params)
      !params[:q].nil?
    end

  
    def save_search_params(session, params)
      search_val = params[:q]
      
      if search_val.blank?
        session[:q] = {params[:controller] => { params[:action] => nil }}
      else 
        session[:q] = {params[:controller] => { params[:action] => search_val }}
      end
    end

    
    def retrieve_search_params(session, params)
      p = session.try(:[],:q).try(:[], params[:controller]).try(:[], params[:action])
      p.nil? ? {} : p
    end



  
  # Checks whether a password is needed or not. For validations only.
  # Passwords are always required if it's a new record, or if the password
  # or confirmation are being set somewhere.
  def remove_password_params_if_blank_password
    if params[:user][:password] == "" and params[:user][:password_confirmation] == ""
      params[:user].delete :password
      params[:user].delete :password_confirmation
    end
  end
  

  def user_params
    params.require(:user).permit(:first_name, :last_name, :email, 
                                  :password, :password_confirmation)
  end

  
  # check if we need password to update user data
    # ie if password or email was changed
    # extend this as needed
    def needs_password?(user)
      user.email != params[:user][:email] ||
        params[:user][:password].present? ||
        params[:user][:password_confirmation].present?
    end  
end









