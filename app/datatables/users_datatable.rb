#TODO Not currently using this. Delete if not used.
require 'forwardable'


class UsersDatatable
  
  extend Forwardable
  def_delegators :@view, :params, :h, :link_to
  def_delegators 'Rails.application.routes', :url_helpers  

  def initialize(view)
    @view = view
    # puts "\n\n\n=====     Params.inspect = #{params.inspect}"
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: User.count,
      iTotalDisplayRecords: User.count,
      aaData: data
    }
  end

private

  def data
    users.map do |usr|
      [
        link_to(usr.last_name, usr),
        h(usr.first_name),
        h(usr.email),
        h(usr.role)
        # link_to(image_tag('icons/edit.png', :title => "Edit " +page.name), edit_page_path(page)) + "  " + link_to(image_tag('icons/show.png', :title => "Show " +page.name), show_page_path(page)) + "  " + link_to(image_tag('icons/delete.png', :title => "Delete " +page.name), page, method: :delete, data: { confirm: 'Are you sure?' })
        # link_to ('Edit <i class="general foundicon-edit"></i>'.html_safe, url_helpers.edit_user_registration_path(user)),
        # link_to ("Delete", url_helpers.user_path(user), :data => { :confirm => "Are you sure?" }, method: :delete)
      ]
    end
  end

  def users
    @users ||= fetch_users
  end

  def fetch_users
    usrs = User.order("#{sort_column} #{sort_direction}")
    usrs = usrs.page(page).per_page(per_page)
    if params[:sSearch].present?
      usrs = Users.all
      usrs.where("first_name like :search or last_name like :search or role like :search or email like :search", 
                          search: "%#{params[:sSearch]}%")
    end
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 25
  end

  def sort_column
    columns = %w[last_name first_name email role]
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end
#  id                     :integer          not null, primary key
#  email                  :string(255)      default(""), not null
#  encrypted_password     :string(255)      default(""), not null
#  reset_password_token   :string(255)
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :string(255)
#  last_sign_in_ip        :string(255)
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)
#  last_name              :string(255)
#  role                   :integer
#