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

  def format_datetime(datetime_obj, format = "%Y-%m-%d %H:%M")
    datetime_obj.blank? ? nil : datetime_obj.strftime(format)
  end
  
  def abbreviate_role(role)
    @role_abbrv ||= { "customer" => "cust", "writer" => "writer", "editor" => "editor", "administrator" => "admin", "sysadmin" => "sadmin"}
    @role_abbrv[role].to_s
  end

  def formatted_field_value(object, field)
    case field
    when :last_name
      link_to "#{object.send(field)}", userx_registration_path(object)
    when :created_at, :last_sign_in_at
      format_datetime(object.send(field))
    when :role
      abbreviate_role(object.send(field))
    else
      object.send(field)
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
