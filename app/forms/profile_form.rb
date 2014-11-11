
# Note the reason we have duplicate first_name and last_name attributes on both User and Profile is that they
# are used on the User to personalize the user experience and it saves us from continuously loading the Profile
# for each request. The User and Profile can each exist independently of the other and each requires an email
# attribute.

class ProfileForm
  include ActiveModel::Model
  include Virtus.model
  
  attr_reader :profile, :user, :requests_card
  
  MIN_PASSWORD_LENGTH = 6
  
  attribute :first_name, String
  attribute :last_name, String
  attribute :email, String
  attribute :street1, String
  attribute :street2, String
  attribute :city, String
  attribute :state, String
  attribute :postal_code, String
  attribute :receive_emails, Boolean
  attribute :password, String
  attribute :role, String
  attribute :source, String
  
  validates_presence_of :email
  validate :verify_complete_mailing_address
  validates_length_of :password, minimum: MIN_PASSWORD_LENGTH,  unless: Proc.new {|e| e.password.blank?}
  validates_format_of :postal_code, with: /\d\d\d\d\d-\d\d\d\d|\d\d\d\d\d/,  unless: Proc.new {|e| e.postal_code.blank?}
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/

  
  STATES = %w(
               AK AL AR AZ CA CO CT DC DE FL GA HI IA ID IL IN KS KY 
               LS MA MD ME MI MN MO MS MT NC ND NE NH NJ NM NV NY OH 
               OK OR PA RI SC SD TN TX UT VA NT WE WI WV WY AA AE AP
              ) 
  
  
  
  def persisted?
    false
  end
   
  
  def initialize(obj = nil)
    if obj == nil # Create
      @profile = Profile.new
      @user = User.new
    else   # Edit
      if obj.class == Profile
        @profile = obj
        @user = find_user_or_empty_object
      elsif obj.class == User
        @user = obj
        @profile = find_profile_or_empty_object
      else
        raise ArgumentError, "Unexpected object Class: #{obj.class}", caller
      end
      sync_duplicate_obj_attributes(profile, user)
      set_object_attributes( self, unique_objects_attributes )
    end
    self.receive_emails = true if profile.new_record?
    self.role = 0 if profile.new_record?
  end

  
  def save(params)
    params.delete(:password) if params[:password].blank?
    titleize_names(params)
    set_object_attributes(self, params)
    set_object_attributes(user, params.slice(*user_param_keys))
    set_object_attributes(profile, params.slice(*profile_param_keys))                                
    if valid?
      unless user.new_record? && !params.has_key?(:password)
        user.save! # saves profile too!
      else
        profile.user_id = nil 
        profile.save!
      end         
      true
    else
      false
    end
  end
  
  

  private
  
  
  
  # Returns a new hash with all keys converted to symbols. This is useful because ActiveRecord.attributes
  # returns keys as strings, while Self.attribtures (via Virtus) returns keys as symbols which is the most 
  # useful form.
  def keys_to_sym(hash)
    sym_key_hash = {}
    hash.each { |k, v|  sym_key_hash[k.to_sym] = v }
    sym_key_hash
  end
  
  # User attributes that are directly modified by ProfileForm
  def user_param_keys(include_virtual_attributes = true)
    params = include_virtual_attributes ? [:first_name, :last_name, :email, :password, :role] : [:first_name, :last_name, :email, :role]
  end
  
  # Profile attributes that are directly modified by ProfileForm
  def profile_param_keys
    [:first_name, :last_name, :email, :street1, :street2, :city, :state, :postal_code, :receive_emails, :source]
  end
  
  def profile_attributes
    keys_to_sym(profile.attributes).slice *profile_param_keys
  end
  
  def user_attributes
    keys_to_sym(user.attributes).slice *user_param_keys
  end


  def unique_objects_attributes()
    profile_attributes.merge(user_attributes)
  end
  
  def virtual_form_params_keys
    [:request_card, :password] 
  end


    # We only need to do this once upon loading the User and Profile Object, because both ojects
    # have 3 attributes in common: :first_name, :last_name, and :email. This is intentional to avoid
    # loading the profile for every request. This method does nothing if the corresponding attributes are 
    # blank?, if only one is blank? then the other is assigned to it, otherwise an exception is thrown if
    # both attributes contain data and the data is not equal.
    def sync_duplicate_obj_attributes(obj1, obj2)
      duplicate_keys.each do |key|
        unless obj1[key].blank? && obj2[key].blank?
          if obj1[key].blank?
            obj1.send("#{key}=", obj2[key])
          elsif obj2[key].blank?
            obj2.send("#{key}=", obj1[key])
          else  # Each obj has a value
            if obj1[key] != obj2[key]
              raise ArgumentError, "#{key} attribute values on the two objects don't match: #{obj1[key]} vs #{obj2[key]}"
            end
          end
        end
      end
    end

    
  
    # Returns an array of keys that exist in User and Profile objects and are used
    # in the ProfileForm object.
    def duplicate_keys
      profile_param_keys & user_param_keys
    end
    

    def clear_profile_form_attributes
      self.attributtes.keys.each { |k| self[k] = nil  }
    end

    def set_object_attributes(obj, params)
      params.each  {|k, v| obj.send(:"#{k}=", filter_role(k, v))}
    end
    
    def filter_role(key, val)
      # byebug
      val = ["customer", "writer", "editor", "administrator", "sysadmin"][val.to_i] if key == :role && (val.class == Fixnum)
      val
    end
  
  
    def find_user_or_empty_object
      if profile.user.blank?
        User.find_by(email: profile.email) || User.new
      else
        profile.user
      end
    end

  
  
    def find_profile_or_empty_object
      if user.profile.blank?
        obj = Profile.find_by(email: user.email) || Profile.new
        user.profile = obj
      else
        user.profile
      end
    end

    def mailing_address_keys
      [:street1, :city, :state, :postal_code ]
    end
    

    def titleize_names(params) 
      [:first_name, :last_name, :city].each { |key| params[key] = params[key].titleize unless params[key].blank?  }
    end

    
    def verify_complete_mailing_address
      blank_ary = []
      nonblank_ary = []
      mailing_address_keys.each { |key| self.send(key).blank? ?  blank_ary << key : nonblank_ary << key }
      if(nonblank_ary.size > 0 && blank_ary.size > 0)
        blank_ary << :first_name if self.first_name.blank?
        blank_ary << :last_name if self.last_name.blank?
        blank_ary.each { |key| self.errors.add(key, " field is blank in a partially completed mailing address.")}
      end 
    end


end