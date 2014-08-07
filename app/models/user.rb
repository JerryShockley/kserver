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



end
