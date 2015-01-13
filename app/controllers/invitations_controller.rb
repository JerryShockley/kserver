class InvitationsController < ApplicationController


  def new
    @profile_form = ProfileForm.new
  end

  def create
    @profile_form ||= ProfileForm.new
    @profile_form.attributes = params[:profile_form] unless params[:profile_form].blank?
    if @profile_form.save(params[:profile_form])
      flash[:notice] = "Record saved successfully!"
      redirect_to(action: :show, id: @profile_form.id)
    else
      flash[:alert] = failed_save_msg(@profile_form)
      render 'new'
    end
    
  end


  def show
    @profile_form = ProfileForm.find(params[:id])
    if @profile_form.nil? 
      flash[:alert] = "Invitation #{params[:id]} was not found"
      redirect_to action: :new
    end
  end

end
