# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :text             default(""), not null
#  encrypted_password     :text             default(""), not null
#  reset_password_token   :text
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :text
#  last_sign_in_ip        :text
#  created_at             :datetime
#  updated_at             :datetime
#  first_name             :string(255)
#  last_name              :string(255)
#  role                   :integer
#

class User < ActiveRecord::Base

  has_one :profile
  has_many :images, dependent: :nullify
  has_many :videos, dependent: :nullify
  has_many :product_apps, dependent: :nullify
  has_many :looks, dependent: :nullify
  has_many :product_clusters, dependent: :nullify
  has_many :product_sets
  has_many :custom_product_sets
  has_many :look_reviews
  has_many :product_reviews
  

  enum role: { 
               customer: 0, 
               writer: 1, 
               editor: 2, 
               administrator: 3, 
               sysadmin: 4
             }

  after_initialize :set_default_role, :if => :new_record?
  
  paginates_per 50
  
  def self.policy_class
      UserPolicy
    end

  validates_presence_of :first_name, :last_name, :email

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable



  
  def set_default_role
   self.role ||= :customer
  end


  def admin?
    self.administrator? ||
    self.sysadmin?
  end

  def staff?
    self.administrator? ||
    self.sysadmin? ||
    self.editor? ||
    self.writer?
  end
  
  # Creates full name for user
  def name
    n = self.first_name + " " + self.last_name
  end
  
  def self.show_attributes
    show_attribs = [:first_name, :last_name, :email, :role, :sign_in_count, :last_sign_in_at,
                    :created_at, :updated_at, :reset_password_sent_at, :remember_created_at ]
    
  end


private

def self.ransackable_attributes(auth_object = nil)
  %w(last_name first_name email role sign_in_count last_sign_in_at created_at ) + _ransackers.keys
end  


end
