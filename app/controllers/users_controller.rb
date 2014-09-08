#TODO add authorization to Registrations controller to limit editing of users

class UsersController < ApplicationController
  before_filter :authenticate_user!
  after_action :verify_authorized

  # TODO Improve table behavior
  def index
    authorize User
    @q = User.search(params[:q])
    @users = @q.result(distinct: true).page(params[:page]).per(75)
    # respond_to do |format|
    #   format.html
      # format.json { render json: UsersDatatable.new(view_context) }
    # end
  end
  
  # def search
  #   authorize User
  #   index
  #   render :index
  # end


  def show
    @user = User.find(params[:id])
    authorize @user
  end

  def update
    @user = User.find(params[:id])
    authorize @user
    if @user.update_attributes(secure_params)
      redirect_to users_path, :notice => "User updated."
    else
      redirect_to users_path, :alert => "Unable to update user."
    end
  end

  def destroy
    user = User.find(params[:id])
    authorize user
    usr = user.name + "\t\t email = #{user.email} \t\t"
    user.destroy
    redirect_to users_path, :notice => "User (#{usr})  deleted."
  end

  private

  def secure_params
    params.require(:user).permit(:role)
  end

end
