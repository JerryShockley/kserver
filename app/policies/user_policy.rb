class UserPolicy
  attr_reader :current_user, :resource

  def initialize(current_user, resource)
    raise Pundit::NotAuthorizedError, "must be logged in" unless current_user 
    @current_user = current_user
    @resource = resource
  end

  def index?
    @current_user.admin?
  end
  
  # def search?
  #   @current_user.admin?
  # end

  def show?
    @current_user.admin? or @current_user.email == @resource.email
  end

  def update?
    @current_user.admin? or @current_user.email == @resource.email
  end
  
  def edit?
    update?    
  end


  def destroy?
    @current_user.admin? or @current_user.email == @resource.email
  end

end
