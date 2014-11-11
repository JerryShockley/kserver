class ProfilesController < ApplicationController
  include PunditHelper
  after_action :verify_authorized, except: [:new, :create]
  
  
  # /profiles
  # def index
  #   load_profile_forms
  # end

  # /profiles/new
  def new
    build_profile
  end
  
  # /profiles  :method post
  def create
    build_profile
    unless save_profile
      flash[:alert] = failed_save_msg(profile_form)
       render 'new'
     end
  end
  
  # /profiles/:email/edit
  def edit
    load_profile
    authorize profile_form.profile
    build_profile
  end
  
  # /profiles/:email  method: patch
  def update
    load_profile
    authorize profile_form.profile
    build_profile
    unless save_profile
      flash[:alert] = failed_save_msg(profile_form)
       render 'edit'
     end
  end
  
  # /profiles/:email
  # def destroy
  #   load_profile_form
  #   destroy_profile_form
  #   redirect_to profiles_path
  # end

  private
  
  def load_profiles
    @profiles ||= profile_scope(false).to_a 
  end
  
  def load_profile
    @profile_form ||= ProfileForm.new(profile_scope)
  end
  
  def build_profile
    @profile_form ||= ProfileForm.new
    @profile_form.attributes = params[:profile_form] unless params[:profile_form].blank?
  end
  
  def save_profile
    if @profile_form.save params[:profile_form]
      redirect_to root_path
    end
  end
  
  def profile_scope(singular = true)
    if singular
      Profile.find(params[:id])
    else
      Profile.all
    end
  end
  
  def profile_form
    @profile_form
  end




end
