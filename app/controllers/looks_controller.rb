class LooksController < ApplicationController
  
  # /profiles
  # def index
  #   load_look_forms
  # end

  # /looks/:id
  def show
    @look = Look.includes(product_sets: {product_clusters: {product_apps: :product}}).find(params[:id])
    @set = @look.product_sets[0]
  end


  # /looks/new
  # def new
  #   build_look
  # end
  #
  # # /looks  :method post
  # def create
  #   build_look
  #   unless save_look
  #     flash[:alert] = failed_save_msg(look_form)
  #      render 'new'
  #    end
  # end
  #
  # # /looks/:email/edit
  # def edit
  #   load_look
  #   authorize look_form.look
  #   build_look
  # end
  #
  # # /looks/:email  method: patch
  # def update
  #   load_look
  #   authorize look_form.look
  #   build_look
  #   unless save_look
  #     flash[:alert] = failed_save_msg(look_form)
  #      render 'edit'
  #    end
  # end
  
  # /looks/:email
  # def destroy
  #   load_look_form
  #   destroy_look_form
  #   redirect_to looks_path
  # end

  private
  
  def load_looks
    @looks ||= look_scope(false).to_a 
  end
  
  def load_look
    @look_form ||= lookForm.new(look_scope)
  end
  
  def build_look
    @look ||= lookForm.new
    @look.attributes = params[:look_form] unless params[:look_form].blank?
  end
  
  def save_look
    if @look.save params[:look_form]
      redirect_to root_path
    end
  end
  
  def look_scope(singular = true)
    if singular
      look.find(params[:id])
    else
      look.all
    end
  end
  
  def look_form
    @look_form
  end

  
end
