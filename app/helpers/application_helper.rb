module ApplicationHelper
  
  def link_to_add_fields(name, f, type)
    new_object = f.object.send "build_#{type}"
    id = "new_#{type}"
    fields = f.send("#{type}_fields", new_object, child_index: id) do |builder|
      render("devise/registrations/users/" + type.to_s + "_fields", f: builder)
    end
    link_to(name, '#', class: "add_#{type}_fields", id: "add_#{type}_fields", data: {id: id, fields: fields.gsub("\n", "")})
  end
  
  
  def error_messages!(obj)
    return "" if obj.errors.empty?    
    messages = obj.errors.full_messages.map { |msg| content_tag(:li, msg) }.join

    html = <<-HTML
    <div id="errorExplanation">
      <ul>#{messages}</ul>
    </div>
    HTML

    html.html_safe
  end
end
