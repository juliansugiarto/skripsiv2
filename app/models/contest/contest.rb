# ================================================================================
# Part:
# Desc:
# ================================================================================
class Contest
  include Mongoid::Document
  include Mongoid::Timestamps
  include ContestSearchable
  include Ownerable

  #                                                                       Constant
  # ==============================================================================
  DESCRIPTION_MAXIMUM_LENGTH = 1000
  DESCRIPTION_SUGGESTED_LENGTH = 600
  # REQUEST_EMAIL_KEYS = eval(AppConfig::request_email_keys)
  WINNER_PENDING_DAY = 4.days # Sekitar 3 harian
  FILE_TRANSFER_DAY = 6.days # Sekitar 5 harian
  PITCHING_WINNER_DAY = 35.days
  NEW_CONTEST_END_DATE = "2013-07-01".to_time
  VAR_need_help_FEE = 300000
  FT_COPYRIGHT_STEP = 'ft-copyright'
  FT_DESIGN_STEP = 'ft-design'
  FT_REVIEW_STEP = 'ft-review'
  FT_DONE_STEP = 'ft-done'
  FT_STEPS_ORDER = [FT_COPYRIGHT_STEP, FT_DESIGN_STEP, FT_REVIEW_STEP, FT_DONE_STEP]
  FORM_VERSION_TWO = 2

  #                                                                          Index
  # ==============================================================================
  index({owner_id: 1})

  #                                                                  Attr Accessor
  # ==============================================================================
  attr_accessor :as_multistep_form
  attr_accessor :current_last_step
  attr_accessor :current_step
  attr_accessor :change_start_date_and_end_date
  attr_accessor :payment_type
  attr_accessor :disable_callback
  attr_accessor :current_user_id

  #                                                                       Callback
  # ==============================================================================
  # after_find do
  #   update_participant
  # end

  before_create do
    set_default_attributes
    check_status
    check_features
  end

  before_save do
    reorder_position
    set_default_attributes
    # send_to_kissmetric
  end

  after_create do
    initiate_winner
    initiate_invoice
  end

  after_save do
    claim_affiliate
    initiate_invoice
    set_sort_points
  end


  #                                                                          Field
  # ==============================================================================
  field :form_version, type: Integer, default: 1 # Bedain form lama dan baru

  # General info
  field :title, type: String
  field :permanent_title, type: String
  field :custom_permanent_title, type: String
  field :slug, type: String
  field :description, type: String
  field :note, type: String # Info for designer (if exists)
  field :additional_info, type: String # old, new == note
  field :max_slot, type: Integer
  field :contest_attachment_group_id
  field :temporary_features, type: Hash, default: {}

  # Duration
  field :duration, type: Integer # by sistem
  field :duration_requested, type: Integer # Diisi ch d form
  field :start_date, type: DateTime
  field :end_date, type: DateTime
  field :closed_at, type: Time # attribute kapan contest di closed

  field :show_on_portfolios, type: Boolean, default: true
  field :log_to_kissmetric, type: Boolean, default: false # flag, apakah sudah pernah kirim data ke kissmetric

  # Flag if contest only testing
  field :testing, type: Boolean, default: false

  # Flag true if contest (not saver) already blast to designers & management
  field :email_blast, type: Boolean, default: false


  # Promotion (sepertinya tidak terpakai)
  # field :merchant_voucher_active, type: Boolean, default: false
  # field :merchant_custom_text_en, type: String
  # field :merchant_custom_text_id, type: String
  # field :merchant_vouchers_pending, type: Array, default: []
  # field :request_email, type: Integer, default: 0

  # TODO:
  # Denormalize count entries
  # field :entries_count, type: Integer, default: 0
  # field :participants_count, type: Integer, default: 0
  # field :comments_count, type: Integer, default: 0

  # denormalize field to store sort point calculated by set_sort_points method
  # used for listing contests in browse contest view
  field :zn_sort_points, type: Integer, default: 0

  # ADDITIONAL ATTRIBUTES
  # attribute tambahan buat sorting di bagian browse contest
  # field :package_name, type: String
  # field :package_position, type: Integer
  # field :status_position, type: Integer

  # SEO
  # Kalau terisi maka redirect to page in value
  field :redirect_to_page, type: String

  # Untuk keperluan SEO di halaman overview (meta title & description)
  field :meta_overview_title_id
  field :meta_overview_title_en
  field :meta_overview_description_id
  field :meta_overview_description_en

  # Untuk keperluan SEO di halaman gallery (meta title & description)
  field :meta_gallery_title_id
  field :meta_gallery_title_en
  field :meta_gallery_description_id
  field :meta_gallery_description_en

  # Untuk display message box ke CH di berbagai macam kondisi
  field :messagebox_ch_gallery_first_visit # Setelah kontes jalan dan CH masuk ke kontes-nya pertama kali
  field :messagebox_ch_desc_first_visit # Ketika CH masuk ke bagian contest description pertama kali
  field :messagebox_ch_first_design_submitted # Ketika ada desain pertama yang masuk di kontes-nya
  field :messagebox_ch_open_to_pending # Ketika kontes berubah dari open -> winner pending
  field :messagebox_ch_winner_pending_1_day_left # Pada saat winner pending di kontes-nya tinggal 1 hari lagi

  # BACKOFFICE
  field :email_sent_budget_notification # Notifikasi untuk upgrade paket kalau kontes budget sudah berakhir / mencapai 15
  field :sent_sms_save_contest # Apakah sudah pernah dikirimkan sms pada saat CH mensave kontes? Hanya kirim 1x saja

  # Unbounce
  field :utm_contest

  # TODO:
  # Migrate this to payment, transaction, deposit if exists
  # DEPRECATED, DELETE AFTER DEPLOY PRODUCTION
  # Payment Confirmation by CH
  field :draft, type: Boolean
  field :confirm_payment_date, type: DateTime # CH manually select from date picker
  field :confirm_payment_info
  field :payment_attachment

  # Payment Confirmation by Admin
  field :admin_payment_date, type: DateTime # Automatically using Time.now. Act as created_at
  field :admin_payment_date_manual, type: DateTime
  field :admin_confirm_payment_bank # Bank select
  field :admin_confirm_payment_nominal
  field :admin_confirm_payment_info
  field :admin_payment_attachment
  field :admin_fee_development, type: Float, default: 0

  # Additional demands (Free) (Services)
  field :guarantee, type: Boolean, default: false
  field :need_patent_registration, type: Boolean, default: false
  field :need_outsource_clothing_production, type: Boolean, default: false
  field :need_outsource_video_production, type: Boolean, default: false
  field :need_outsource_web_development, type: Boolean, default: false
  field :need_outsource_online_marketing, type: Boolean, default: false
  field :need_outsource_printing, type: Boolean, default: false
  field :need_outsource_production, type: Boolean, default: false
  field :need_outsource_web_hosting, type: Boolean, default: false
  field :bulk_order, type: Boolean, default: false

  # Do not let google index contest overview (other tab pages are no index by default)
  field :noindex, type: Boolean, default: false

  # mark if is retention contest 
  field :retention, type: Integer

  #                                                                       Relation
  # ==============================================================================
  # Owner as polymorphic, in case in the future not only member can create contest
  belongs_to :owner, polymorphic: true
  belongs_to :category
  belongs_to :package
  belongs_to :status, class_name: "ContestStatus" # Default to draft
  belongs_to :industry

  has_many :extra_field_values, class_name: "OldExtraFieldValue"
  has_many :comments, as: :commentable
  has_many :likes, as: :likeable
  has_many :entries
  has_many :winners
  has_many :agreements
  has_many :contest_features
  has_many :contest_services
  has_many :attachments, class_name: "ContestAttachment"
  has_many :participations
  has_many :holders, class_name: "Membership", foreign_key: "contest_id"

  has_many :invoices, class_name: "ContestInvoice" # As flag only
  has_one :invoice_item, as: :purchasable
  has_one :detail

  has_many :upgrades, class_name: "ContestUpgrade"

  # Affiliate
  has_one :affiliate_referred_by, class_name: "AffiliateClaimContest", foreign_key: "contest_id" # Referred affiliate

  #ticket
  has_many :contest_unpaid_tickets
  has_many :feature_upgrade_tickets
  has_many :package_upgrade_tickets
  has_many :runner_up_tickets
  has_many :cancel_tickets
  has_many :file_transfer_tickets
  has_many :winner_pending_tickets

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================
  def features
    Feature.where(:id.in => self.contest_features.map(&:feature_id))
  end

  def services
    Service.where(:id.in => self.contest_services.map(&:service_id))
  end

  def workspaces
    ContestWorkspace.where(contest: self)
  end

  def entries_count
    self.entries.count
  end

  def participants_count
    self.participations.count
  end

  def comments_count
    self.comments.count
  end

  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :title, :message => :custom_presence
  validates_uniqueness_of :slug
  validates_presence_of :owner
  validates_presence_of :industry
  validates :description, :length => {:maximum => DESCRIPTION_MAXIMUM_LENGTH}


  #                                                                   Class Method
  # ==============================================================================
  class << self
    # Get contest confidential_only
    def confidential_only
      contest_ids = ContestFeature.where(:feature_id.in => [Feature.as_confidential]).map(&:contest_id).uniq
      Contest.where(:id.in => contest_ids)
    end

    def private_only
      contest_ids = ContestFeature.where(:feature_id.in => [Feature.as_private]).map(&:contest_id).uniq
      Contest.where(:id.in => contest_ids)
    end
  end

  #                                                                Instance Method
  # ==============================================================================
  def get_top_designers(number = 1)
    entries = self.entries.desc(:rating)
    designers = []
    i = 0
    entries.each do |e|

      unless designers.include? e.owner
        designers << e.owner
        i = i + 1
      end

      break if i == number
    end

    return designers
  end

  def get_top_entries(number = 1)
    entries = []
    designers = []
    i = 0
    self.entries.desc(:rating).each do |e|

      unless designers.include? e.owner
        designers << e.owner
        entries << e
        i = i + 1
      end

      break if i == number
    end

    return entries
  end

  def is_naming_contest?
    self.category.cname == "naming_tagline"
  end

  def is_entries_hidden?
    if self.is_confidential?
      return true
    elsif self.is_private?
      return false if self.is_closed?
      return true
    else
      return false
    end
  end

  def is_testing?
    self.testing
  end

  def is_designer_winner?(member = nil)
    self.winners.map {|w| w.designer}.include?(member)
  rescue
    false
  end

  def is_first_contest?
    self.owner.contests.count == 1
  end

  def is_confidential?
    self.features.include? Feature.as_confidential
  end

  def is_private?
    self.features.include? Feature.as_private
  end

  # Packages
  def is_package_saver?
    self.package.is_saver?
  end

  def is_package_bronze?
    self.package.is_bronze?
  end

  def is_package_silver?
    self.package.is_silver?
  end

  def is_package_gold?
    self.package.is_gold?
  end

  def is_package_platinum?
    self.package.is_platinum?
  end

  # Statuses
  def is_draft?
    self.status == ContestStatus.draft
  end

  def is_not_active?
    self.status == ContestStatus.not_active
  end

  def is_open?
    self.status == ContestStatus.open
  end

  def is_winner_pending?
    self.status == ContestStatus.winner_pending
  end

  def is_file_transfer?
    self.status == ContestStatus.file_transfer
  end

  def is_closed?
    self.status == ContestStatus.closed
  end

  def is_no_winner?
    self.status == ContestStatus.no_winner
  end

  def is_refund?
    self.status == ContestStatus.refund
  end


  # Transaction fee
  def calculate_transaction_fee
    return self.package.prize * Percentage::TRANSACTION_FEE / 100
  end

  # Posting fee
  def calculate_posting_fee
    if self.package.is_saver?
      return 0
    else
      return Percentage::POSTING_FEE
    end
  end

  def calculate_package_prize
    return self.package.prize
  end

  # Calculate actual prize for designer
  def calculate_prize
    # If no winner contest, calculate from all winner
    if self.is_no_winner?
      self.winners.sum(:prize)

    # If contest normal, calculate from first winner
    else
      self.winners.find_by(position: 1).try(:prize)
    end

  end

  def get_first_winner
    self.winners.find_by(position: 1)
  end

  # Get first entry
  def get_first_entry
    self.entries.first
  rescue
    nil
  end

  # Get featured images
  def get_featured_images(n=3)
    self.entries.take(3).map(&:image_url)
  rescue
    []
  end

  # Create affiliate claim if contest is first contest
  def claim_affiliate
    # Claim affiliate
    raise if !self.is_first_contest?
    raise if AffiliateClaimContest.where(contest: self).present?

    # Find owner referred by
    affiliate = self.try(:owner).try(:affiliate_referred_by).try(:affiliate)
    raise if affiliate.blank?

    # Find affiliate publisher
    publisher = affiliate.publisher

    # Hitung commission berdasarkan berapa banyak publisher telah menghasilkan
    # contest yang berhasil di close (bayar)
    aff_success = publisher.affiliate_referring(type: "contest", status: "success")
    if aff_success.count < 10
      commission = AffiliateCommissionContest.find_by(quantity: 0)
    elsif aff_success.count >= 10
      commission = AffiliateCommissionContest.find_by(quantity: 10)
    end

    # Create AffiliateClaim record
    # Commission akan diberikan ketika contest statusnya closed
    AffiliateClaimContest.create(affiliate: affiliate, contest: self, commission: commission)

  rescue
    nil
  end

  def set_default_attributes
    # Only set for the first time
    self.permanent_title = self.title if self.permanent_title.blank?
    self.custom_permanent_title = self.permanent_title.parameterize if self.custom_permanent_title.blank?

    self.max_slot = self.package.try(:slot) unless self.max_slot.present?
    self.slug = "#{self.title.to_s.parameterize}-#{self.id}"

    self.duration = self.duration_requested if self.duration.blank?
    self.duration_requested = self.duration if self.duration_requested.blank?
  end

  def initiate_invoice
    # Only if contest draft
    if self.status == ContestStatus.draft

      # Create InvoiceItem
      # Contest save as purchased items
      if self.invoice_item.blank?
        invoice = ContestInvoice.create(owner: self.owner, contest: self)
        item = InvoiceItemContest.create(invoice: invoice, purchasable: self)
      else
        item = self.invoice_item
        invoice = item.invoice
      end

      # General fields
      item.description = "Contest #{self.title}"
      item.quantity = 1
      item.discount = 0

      # Prize
      item.package_prize = self.calculate_package_prize

      # CALCULATE FEE
      # Posting fee
      if self.package.is_saver?
        item.posting_fee = 0
      else
      end

      # Transaction fee
      item.posting_fee = self.calculate_posting_fee
      item.transaction_fee = self.calculate_transaction_fee

      # Calculate features price
      if self.contest_features.present?
        self.contest_features.each do |cf|
          item.send "#{cf.feature.cname}_price=", cf.feature.price
        end
      else
        item.private_price = 0
        item.confidential_price = 0
        item.fast_tracked_price = 0
        item.extend_price = 0
        item.guarantee_price = 0
      end

      # If naming contest, get free confidential
      if self.category.cname == 'naming_tagline'
        confidential = Feature.find_by(cname: "confidential")
        if self.contest_features.where(feature: confidential).present?
          item.send "#{confidential.cname}_price=", 0
        end
      end

      item.calculate_total
      item.save

    end




  end

  def initiate_winner
    # Initial winner for first time
    if self.winners.blank?
      self.winners.create(
        position: 1,
        winner_type: WinnerType.as_winner,
        prize: self.package.prize,
        client: self.owner,
        status: WinnerStatus.open
      )
    end
  end


  def check_features
    features = self.contest_features.map(&:feature_id)

    prvt = Feature.find_by(cname: "private")
    conf = Feature.find_by(cname: "confidential")
    fast = Feature.find_by(cname: "fast_tracked")
    extnd = Feature.find_by(cname: "extend")

    # Mencegah agar feature private dan confidential tidak ada dlm satu kontes
    if features.include? prvt.try(:id)
      self.contest_features.each do |f|
        if f.feature.name == conf.try(:cname)
          self.contest_features.delete(f)
        end
      end
    end

    # Mencegah tidak ada feature fast_tracked dan extend tidak ada dalam satu kontest
    if features.include? fast.try(:id)
      self.contest_features.each do |f|
        self.contest_features.delete(f) if f.feature.cname == extnd.try(:cname)
      end
    end

  end

  def check_status
    if self.status.present?
      case self.status.cname
      when "draft"
        self.start_date = nil
        self.end_date = nil
        self.draft = true
      when "not_active"
        self.start_date = nil
        self.end_date = nil
        self.draft = false
      when "open"
        if self.premium_contest || self.change_start_date_and_end_date.blank? && (self.start_date_changed? || self.end_date_changed?)
          if self.contest_features.map(&:cname).include?("fast_tracked")
            feature = self.contest_features.where(:cname => "fast_tracked").first
            self.start_date = Time.now
            temp_end_date = feature.how_long.to_i.days.from_now
            self.end_date = Time.local(temp_end_date.year,temp_end_date.month,temp_end_date.day,0,0)
          elsif self.duration.present?
            self.start_date = self.start_date.present? ? self.start_date : Time.now
            temp_end_date = self.start_date + self.duration.days
            self.end_date = Time.local(temp_end_date.year,temp_end_date.month,temp_end_date.day,0,0)
          elsif self.duration_requested.present?
            # Dateng dari admin ngeapprove upgrade paket budget ke atasnya.
            # Jangan ngapa2in karena perubahan end_date sudah di handle di admin/features_controller.rb:15
          elsif self.package_name == "budget"
            temp_end_date = Time.now + Package::BUDGET_DURATION.days
            self.end_date = Time.local(temp_end_date.year,temp_end_date.month,temp_end_date.day,0,0)
          else
            AdminMailerWorker.perform_async(perform: :debug_email, subject: "Ada yang masuk ke block contest.rb line 1039", params: "Ada yang masuk ke block contest.rb line 471")
          end
          self.request_email = REQUEST_EMAIL_KEYS[:sbiz_open_notify] if self.premium_contest
        end
        self.draft = false
      end
    else
      self.status = ContestStatus.draft
      self.start_date = nil
      self.end_date = nil
    end

  end

  def send_to_kissmetric
  end

  def reorder_position
  end

  def first_winner
    self.winners.where(:position => 1).first
  end

  def set_sort_points
    # decide sort points of each contest for listing in browse contest
    # sort points calculated based on status, and end date of a contest
    # rules are as follows:
    # - 100 points = non-saver and open and will end in 3 days
    # - 90 points = non-saver and open
    # - 80 points = saver and open and will end in 3 days
    # - 70 points = saver and open
    # - 50 points = file transfer
    # - 40 points = non-saver and not closed
    # - 30 points = non-saver and closed
    # - 20 points = saver and not closed
    # - 10 points = saver and closed

    sort_points = 0
    if self.status == ContestStatus.file_transfer
      sort_points = 50
    elsif self.package.is_saver?
      if self.status == ContestStatus.open
        if self.ends_in_3_days?
          sort_points = 80
        else
          sort_points = 70
        end
      elsif self.status == ContestStatus.closed
        sort_points = 10
      else
        sort_points = 20
      end
    else
      if self.status == ContestStatus.open
        if self.ends_in_3_days?
          sort_points = 100
        else
          sort_points = 90
        end
      elsif self.status == ContestStatus.closed
        sort_points = 30
      else
        sort_points = 40
      end
      # reduce points based on whether package is bronze, silver, or gold
      # so the display is in this order: gold, silver, bronze
      deduction = 0
      deduction = 1 if self.package.is_silver?
      deduction = 2 if self.package.is_bronze?
      sort_points = sort_points - deduction
    end
    # use set to avoid callback being called
    # do not need to update if sort points is still the same
    self.set(zn_sort_points: sort_points) unless self.zn_sort_points == sort_points
    sort_points
  end

  def ends_in_3_days?
    self.end_date > DateTime.now and self.end_date < (DateTime.now + 3.days)
  end

  def calculate_winner_pending_deadline
    (self.end_date - DateTime.now).to_i
  end

end
