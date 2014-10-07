class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception



  protected
  
  # Creates a path returning from the requester if the referrer url is present. 
  # You may also add customer parameters to the query string as a hash via the 
  # new_params parameter. If there is no referrer url 
  
  def back_path(new_params: {}, rescue_path: root_path) 
    # rescue in case referrer_url is missing
    referrer_url = URI.parse(request.referrer) rescue URI.parse(rescue_path) 

    if new_params.any?
      referrer_url.query = add_query_parameters(referrer_url: referrer_url, 
                                                new_params: new_params)
    end
    referrer_url.to_s
  end
  
  def add_query_params(referrer_url, params_hash)
    Rack::Utils.parse_nested_query(referrer_url.query).merge(params_hash).to_query
  end



                                             
end
