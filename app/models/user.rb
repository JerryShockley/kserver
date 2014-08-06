class User < ActiveRecord::Base
  enum role: [ :student, :parent1, :teacher, :administrator, :sysadmin ]

  after_initialize :set_default_role, :if => :new_record?

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable

  
  def set_default_role
    self.role ||= :student
  end
  
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable
  
  def admin?
    self.role == :administrator ||
    self.role == :sysadmin
  end

  def faculty?
    self.role == :administrator ||
    self.role == :sysadmin ||
    self.role == :teacher
  end



end
