class RansackSearch
  
  attr_accessor :search, :record_count, :records, :klass, :search_params

  # Klass is the class used to call search.
  def initialize(klass_param)
    @klass = klass_param
  end

  def execute_search(session, params, distinct_recs = true)    
    if referrer_is_index?(params)
      save_search_params(session, params) 
      @search_params = params[:q]
    else
      @search_params = retrieve_search_params(session, params)  
    end
    @search = User.search(search_params)
    @record_count ||= search.result(distinct: distinct_recs).count
    @records = search.result(distinct: distinct_recs).page(params[:page])
    search.build_condition if search.conditions.empty?
    search.build_sort if search.sorts.empty?  
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



  private

  def referrer_is_index?(params)
    !params[:q].nil?
  end


end

