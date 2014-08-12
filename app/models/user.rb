# == Schema Information
#
# Table name: users
#
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

class User < ActiveRecord::Base
  enum role: [ :student, :parent1, :teacher, :administrator, :sysadmin ]

  after_initialize :set_default_role, :if => :new_record?

  validates_presence_of :first_name, :last_name, :email
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  
  def set_default_role
    self.role ||= :student
  end
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  def admin?
    self.administrator? ||
    self.sysadmin?
  end

  def faculty?
    self.administrator? ||
    self.sysadmin? ||
    self.teacher?
  end
  
  # Creates full name for user
  def name
    n = self.first_name + " " + self.last_name
  end




end
