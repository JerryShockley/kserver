module UsersHelper
  
  def model_fields
    # which fields to display and sort by
    @_model_fields ||= User.ransackable_attributes.map {|a| a.to_sym}
  end

  # def results_limit
  #   # max number of search results to display
  #   75
  # end

  def display_query_sql(users)
    "SQL: #{users.to_sql}"
  end



  def display_results_header(count)
    msg = "Your search found "
    case count
    when 0
      msg << "no records"
    when 1
      msg << "1 record"
    else
      msg << "#{count} records"
    end
  end

 
  def display_sort_column_headers(search)
    ch = model_fields.each_with_object('') do |field, string|
      string << content_tag(:th, sort_link(search, field, {}, method: :put))
    end
    ch << content_tag(:th, "Operations")
  end

  def display_search_results(objects)
    # objects.limit(results_limit).each_with_object('') do |object, string|
    objects.each_with_object('') do |object, string|
      string << content_tag(:tr, display_search_results_row(object))
    end
  end

  
  def build_operations_cell_data(usr)
    # TODO Add icons for operations
    
    link_to('Edit', edit_userx_registration_path(usr), id: "edit_#{usr.id}") + " | " +  
          link_to('Delete', userx_registration_path(usr), id: "delete_#{usr.id}",
                  :data => { :confirm => "Are you sure?" }, method: :delete)
  end


  def display_search_results_row(object)
    ch = model_fields.each_with_object('') do |field, string|
      if field == :last_name
        string << content_tag(:td, (link_to "#{object.send(field)}", userx_registration_path(object)))
      else
        string << content_tag(:td, object.send(field))
      end
    end    
    ch << content_tag(:td, build_operations_cell_data(object))
    ch.html_safe
  end
  
  
end


# table#users
#   thead
#     tr
#       th = sort_link @search, :last_name, "Last Name", default_order: :desc
#       th = sort_link @search, :first_name, "First Name"
#       th = sort_link @search, :email, "Email"
#       th = sort_link @search, :role, "Role"
#       th = sort_link @search, :last_sign_in_at, "Last Sign in"
#       th = sort_link @search, :created_at, "Created"
#       th = "Operations"
#   tbody
#      - for usr in @users do
#       tr
#         td = link_to "#{usr.last_name}",  userx_registration_path(usr)
#         td = usr.first_name
#         td = usr.email
#         td = usr.role
#         td = usr.last_sign_in_at
#         td = usr.created_at
#         /TODO Add icons for operations
#         td = link_to('Edit', edit_userx_registration_path(usr), id: "edit_#{usr.id}") + " | " +                               link_to('Delete', user_registration_path(usr), id: "delete_#{usr.id}",
#                        :data => { :confirm => "Are you sure?" }, method: :delete)
#   = paginate(@users)
