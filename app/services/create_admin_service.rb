class CreateAdminService
  def call
    puts "made it to call:  #{Rails.application.secrets.admin_email}"
    user = User.find_or_create_by!(email: Rails.application.secrets.admin_email) do |user|
      puts"enter loop"
        user.password = Rails.application.secrets.admin_password
        user.password_confirmation = Rails.application.secrets.admin_password
        user.admin!
      end
  end
end
