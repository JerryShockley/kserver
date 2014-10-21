module UsersHelper
  
  def model_fields
    # which fields to display and sort by
    @_model_fields ||= User.ransackable_attributes.map {|a| a.to_sym}
  end

 
  def build_cancel_path
    if current_user.admin?
      search_users_path
    else
      root_path
    end
  end


  def display_results_count(count)
    msg = "Your search found "
    case count
    when 0
      msg << "no records"
    when 1
      msg << "1 record"
    else
      msg << "#{count} records"
    end
    msg.html_safe
  end  
  
end
