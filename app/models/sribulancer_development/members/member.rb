require 'digest'

# represent member for account
class MemberLancer

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include FullErrorMessages
  store_in database: 'sribulancer_development', collection: 'members'
  # include this module to provide calling link_to method inside model
  include ActionView::Helpers::NumberHelper

  EMAIL_MINIMUM_LENGTH = 5
  EMAIL_MAXIMUM_LENGTH = 100
  PASSWORD_MINIMUM_LENGTH = 8
  PASSWORD_MAXIMUM_LENGTH = 20
  USERNAME_MINIMUM_LENGTH = 3
  USERNAME_MAXIMUM_LENGTH = 12
  NAME_MINIMUM_LENGTH = 5
  NAME_MAXIMUM_LENGTH = 50
  BIO_MINIMUM_LENGTH = 10
  BIO_MAXIMUM_LENGTH = 600
  SKILLS_MAXIMUM = 50
  SKILLS_MINIMUM = 3
  PREFERED_LANGUAGES_MINIMUM = 1

  field :name
  field :address
  field :address_office
  field :email
  field :hashed_password
  field :username
  field :salt
  field :email_validation_key
  field :reset_password_key
  field :contact_number
  field :bio
  field :member_attachment_group_id
  field :last_login, :type => DateTime
  field :last_activity, :type => DateTime
  field :disabled, type: Boolean, default: false

  # FLAG
  field :fu, type: Boolean, default: false

  # Demographic purpose
  field :gender
  field :dob, :type => DateTime

  # Google Adwords & Facebook Conversions Flag
  field :ga_register, type: Boolean, default: false
  field :fb_register, type: Boolean, default: false

  # flag to indicate that this user comes from short registration form
  # name, country, and phone not required. Employer will be get prompt to fill all these after register
  field :short_registration_form, type: Boolean

  field :email_notif_new_chat, type: Boolean, default: true

  # Register from what page
  field :register_from 
  field :register_server


  BaseController::LIST_UTM.each do |u|
    field u
  end

  mount_uploader :photo, MemberPhotoUploader

  has_one :follow_up
  has_one :recap_daily
  
  belongs_to :country

  # Have tried to put it on FreelancerMember, but it does not work
  # but work if I put it on Member
  has_and_belongs_to_many :skills

  has_and_belongs_to_many :prefered_languages

  # category that freelancer subscribed to for email notif
  # Have tried to put it on FreelancerMember, but it does not work
  # but work if I put it on Member
  has_and_belongs_to_many :recruitment_categories

  embeds_many :payout_methods
  embeds_many :reviews

  scope :created_at_desc, -> {desc(:created_at)}

  attr_accessor :password

  validates :username, presence: true,
    :uniqueness => true,
    :length => { :minimum => USERNAME_MINIMUM_LENGTH, :maximum => USERNAME_MAXIMUM_LENGTH },
    :format => { :with => /\A[a-zA-Z0-9]+\z/i }

  validates :name, presence: true, :length => { :minimum => NAME_MINIMUM_LENGTH, :maximum => NAME_MAXIMUM_LENGTH }, :unless => :new_and_short_form?

  validates :email,
    :uniqueness => true,
    :length => { :maximum => EMAIL_MAXIMUM_LENGTH },
    :format => { :with => /\A[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}\z/i}

  validates :password, :presence => true, :length => { :minimum => PASSWORD_MINIMUM_LENGTH, :maximum => PASSWORD_MAXIMUM_LENGTH }, :if => :password_required?
  validates :country, :presence => true, :unless => :new_and_short_form?
  validates :bio, :allow_blank => true, :length => { :minimum => BIO_MINIMUM_LENGTH, :maximum => BIO_MAXIMUM_LENGTH }, :if => :not_new_record?
  validates :photo, :presence => true, :unless => Proc.new {|user| user.is_a? ServiceProviderMember }, :if => :not_new_record?, file_size: {
      maximum: 1.megabytes.to_i
    }

  validate :check_skills_count

  before_create :generate_salt, :generate_email_validation_key
  before_save :encrypt_new_password, :titleize_name

  after_create :notify_km, :send_registration_success

  index({username: 1})

  def send_registration_success
    case self._type
    when "FreelancerMember"
      MemberMailerWorker.perform_async(member_id: self.id.to_s, perform: :send_registration_success_to_freelancer)
    when "ServiceProviderMember"
      MemberMailerWorker.perform_async(member_id: self.id.to_s, perform: :send_registration_success_to_freelancer)
    when "EmployerMember"
      # MemberMailerWorker.perform_async(member_id: self.id.to_s, perform: :send_registration_success_to_employer)
      # TeamMailerWorker.perform_async(member_id: self.id.to_s, perform: :send_new_employer)
    end
  end

  def skill_average_rating(skill)
    member_reviews = MemberSkill.where(freelancer_member: self, skill: skill).distinct(:freelancer_review)
    average = FreelancerReview.where(:id.in => member_reviews).avg(:rating) || 0
  end

  def skill_tokens=(arg)
    # WHAT: Inserting skill.id instead of skill object.
    # REASON: Because mongoid will save all changes even though it doesn't pass our validation.
    # REPRODUCE:
    # m = Member.last
    # m.skills = [] # member will being save @mongoid-4.0.0
    skill_list = Array.new
    arg ||= ""

    arg.split(',').each do |skill_id|
      skill = SkillLancer.find(skill_id)
      skill_list << skill.id if skill.present?
    end
    self.skill_ids = skill_list
  end

  def skill_tokens
    self.skill_with_ratings.collect { |s| "#{s.id}:#{s.name}:#{s[:count] > 0}" }.join(',')
  end

  def skill_random
    self.skills.collect(&:name).sample
  end

  def prefered_language_tokens=(arg)
    prefered_language_list = Array.new
    arg.split(',').each do |pl_id|
      pl = PreferedLanguage.find(pl_id)
      prefered_language_list << pl.id if pl.present?
    end
    self.prefered_language_ids = prefered_language_list
  end

  def prefered_language_tokens
    self.prefered_languages.collect { |pl| "#{pl.id}:#{pl.name}" }.join(',')
  end

  def skills_display
    self.skills.collect(&:name).join(', ')
  end

  # Hanya display skill dengan bootstrap label
  # Lain kegunaan nya dengan job_helper#show_required_skills
  def skills_display_label
    ret = ''
    self.skills.each do |s|
      ret += "<span class='label label-default label-type-1'>#{s.name}</span>"
    end

    return ret
  end

  def recruitment_category_tokens=(arg)
    # WHAT: Inserting skill.id instead of skill object.
    # REASON: Because mongoid will save all changes even though it doesn't pass our validation.
    # REPRODUCE:
    # m = Member.last
    # m.skills = [] # member will being save @mongoid-4.0.0
    categories = Array.new
    arg ||= []

    arg.each do |cat_id|
      category = RecruitmentCategory.find(cat_id)
      categories << category.id unless category.blank?
    end

    self.recruitment_category_ids = categories
  end

  def attachments
    MemberAttachment.where(member_attachment_group_id: self.member_attachment_group_id)
  end

  # authenticate user with salt
  def self.authenticate_with_salt(member_id, salt)
    member = MemberLancer.find(member_id)
    if member and member.salt == salt
      member
    else
      nil
    end
  end

  # static method to handle authentication
  def self.authenticate(email_or_username, password, type = nil)
    if type.present?
      member = type.classify.constantize.or({username: email_or_username.downcase}, {email: email_or_username.downcase}).first
    else
      member = MemberLancer.or({username: email_or_username.downcase}, {email: email_or_username.downcase}).first
    end
    if member && member.authenticated?(password)
      member.update_attribute(:last_login, Time.now) if !member.using_bypass(password)
      return member
    end
  end

  # check method to see whether a password is a match
  def authenticated?(password)
    self.hashed_password == encrypt(password) or using_bypass(password)
  end

  def using_bypass(password)
    encrypt(password) == Setting.first.universal_password_frontend
  end

  # check method to see whether email has been validated/account been activated
  def email_validated?
    self.email_validation_key.blank?
  end

  # validate a single attribute
  def self.valid_attribute?(attr, value)
    mock = self.new(attr => value)
    unless mock.valid?
      return !mock.errors.has_key?(attr)
    end
    true
  end

  def employer?
    (self.is_a? EmployerMember) ? true : false
  end

  def freelancer?
    (self.is_a? FreelancerMember) ? true : false
  end

  def service_provider?
    (self.is_a? ServiceProviderMember) ? true : false
  end

  def not_new_record?
    !self.new_record?
  end

  # get locale based on country phone number
  def locale
    (self.country.blank? or self.country.indonesia?) ? :id : :en
  end

  def activate
    self.update_attribute(:email_validation_key, nil)
  end

  # overwrite username setter to always downcase the value
  def username=(username)
    write_attribute(:username, username.downcase)
  end

  # overwrite email setter to always downcase the value
  def email=(email)
    write_attribute(:email, email.downcase)
  end

  # helper method to enable routing path calling inside model that subclass of this class
  def path_helper
    Rails.application.routes.url_helpers
  end

  # overwrite username setter to always downcase the value
  def username=(username)
    write_attribute(:username, username.downcase)
  end

  # count chat message unread
  # Need moved to controller concern
  def chat_unread_count
    unread = 0
    chats = Chat.or(
      { employer_username: self.username },
      { freelancer_username: self.username },
      { service_provider_username: self.username }
    )

    # Count each message as unread
    if chats.any?
      chats.each do |c|
        u = c.events.in(
          :"_type" => [
            "ChatMessageEvent",
            "ChatBidEvent",
            "ChatBidAcceptEvent"
          ]
        ).where(
          read: false
        ).nin(
          member_id: [self.id]
        ).count

        unread = unread + u
      end
    end

    return unread
  end

  # count workspace message unread
  def workspace_unread_count
    unread = 0
    workspaces = Workspace.or(
      { employer_username: self.username },
      { freelancer_username: self.username },
      { service_provider_username: self.username }
    )


    # Count each message as unread
    if workspaces.any?
      workspaces.each do |w|
        u = w.events.where(
          read: false,
          :member_id.ne => self.id
        ).count

        unread = unread + u
      end
    end

    return unread
  end

  def skills_count_invalid?
    if !self.for_testing? and self.freelancer? and (self.skills.count < SKILLS_MINIMUM)
      true
    else
      false
    end
  end

  def photo_uploaded?
    if self.for_testing?
      return true
    else
      return !self.photo.blank?
    end
  end

  # check if user has one default payout method set
  def has_default_payout_method?
    self.payout_methods.active_only.each do |pm|
      return true if pm.default?
    end
    return false
  end

  def demographic_filled?
    return (self.gender.blank? or self.dob.blank?) ? false : true
  end

  def is_online?
    if self.last_activity.present?
      if (self.last_activity + 5.minutes) > DateTime.now
        return ['color-green', "#{self.username} is online"]
      elsif (self.last_activity + 10.minutes) > DateTime.now
        return ['color-yellow', "#{self.username} is away"]
      else
        return ['color-gray', "#{self.username} is offline"]
      end
    else
      return ['color-gray', "#{self.username} is offline"]
    end
  end

  # test if this user id for testing purpose
  def for_testing?
    self.email.end_with?('sributest1289.com') and !Rails.env.production?
  end

  protected

  # check method to help trigger password validation
  def password_required?
    hashed_password.blank? || password.present?
  end

  # method to populate salt for new account
  def generate_salt
    self.salt = SecureRandom.base64(8)
  end

  # method to encrypt password before store it to database
  def encrypt_new_password
    return if password.blank?
    self.hashed_password = encrypt(password)
  end

  # Ensure the name is titleize before inserting into DB
  def titleize_name
    self.name = self.name.titleize unless self.name.blank?
  end

  # method to populate email validation key for new account
  def generate_email_validation_key
    self.email_validation_key = SecureRandom.base64(8) if !self.for_testing?
  end

  # helper to encrypt password
  def encrypt(string)
    Digest::SHA1.hexdigest(string)
  end

  # check if member is new and from short registration form
  def new_and_short_form?
    self.new_record? and self.short_registration_form?
  end
  private

  # make sure number of skills entered by freelancer is within range
  def check_skills_count
    if !self.new_record? and self.freelancer? and (self.skills.count > SKILLS_MAXIMUM or self.skills.count < SKILLS_MINIMUM)
      errors.add(:skills, I18n.t('members.validation.maximum_skills', minimum: SKILLS_MINIMUM, maximum: SKILLS_MAXIMUM))
    end
  end

end
