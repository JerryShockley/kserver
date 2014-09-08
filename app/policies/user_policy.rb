class UserPolicy
  attr_reader :current_user, :model

  def initialize(current_user, model)
    raise Pundit::NotAuthorizedError, "must be logged in" unless current_user 
    @current_user = current_user
    @model = model
  end

  def index?
    @current_user.admin?
  end
  
  # def search?
  #   @current_user.admin?
  # end

  def show?
    @current_user.admin? or @current_user.email == @model.email
  end

  def update?
    @current_user.admin? or @current_user.email == @model.email
  end
  
  def edit?
    @current_user.admin? or @current_user.email == @model.email    
  end


  def destroy?
    return false if @current_user == @model
    @current_user.admin?
  end

end
