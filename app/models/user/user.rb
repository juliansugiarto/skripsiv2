# ================================================================================
# Part:
# Desc:
# ================================================================================
class User
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include ActiveModel::SecurePassword

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :email, type: String
  field :username, type: String
  field :active, type: Boolean, default: false

  field :last_assigned, type: DateTime

  # Old password, using MD5
  field :old_password, type: String

  # New password, with bcrypt
  field :password_digest, type: String
  field :salt, type: String
  has_secure_password validations: false


  #                                                                       Relation
  # ==============================================================================
  has_many :comments, as: :author
  has_many :transaction_references, as: :reference
  has_many :workers, class_name: "Ticket", inverse_of: :assigned_to
  has_many :requesters, class_name: "Ticket", inverse_of: :assigned_by

  belongs_to :user_group
  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :email, :username
  validates_presence_of :password, on: :create
  validates_confirmation_of :password
  validates_uniqueness_of :email,:username
  validates_format_of :email, with: /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i

  #                                                                   Class Method
  # ==============================================================================
  class << self

    # Authentication with bcrypt
    def authentication(user_params)
      user = User.find_by(username: user_params[:username])
      raise if user.blank?
      password_digest = user.password_digest || BCrypt::Password.create("my secret")
      if BCrypt::Password.new(password_digest).is_password?(user_params[:password])
        return user
      else
        md5_password = Digest::MD5::hexdigest(user_params[:password])
        if user.old_password == md5_password
          # Change MD5 password into BCrypt
          user.password = user_params[:password]
          user.save!
          return user
        else
          raise
        end
      end
    rescue
      return nil
    end

  end


  #                                                                        Private
  # ==============================================================================
  private
  # Ensure the username and email is downcase before saving
  def downcase_attributes
    self.email = self.email.downcase if self.email.present?
    self.username = self.username.downcase if self.username.present?
  end

  # Ensure the name is titleize before saving
  def titleize_attributes
    self.name = self.name.titleize if self.name.present?
  end

  def generate_salt
    self.salt = SecureRandom.base64(8)
  end

end
