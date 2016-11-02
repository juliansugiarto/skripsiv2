# ================================================================================
# Part:
# Desc:
# ================================================================================
class Winner
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ownerable

  #                                                                       Constant
  # ==============================================================================
  WINNER_PAYMENT = ['pending', 'approve']
  WINNER_LIMIT_REQUEST_PAYOUT = 200000

  #                                                                          Index
  # ==============================================================================
  index({contest_id: 1})
  index({entry_id: 1})

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_create do
    set_default_attributes
  end

  #                                                                          Field
  # ==============================================================================
  field :position, type: Integer, default: 0
  field :prize, type: Float, default: 0
  field :chosen_date, type: DateTime
  # Closed berubah jadi true ketik CH selesai memberikan testimonial / review kepada winner via file transfer.
  field :closed, type: Boolean, default: false
  # Flag if prize was raised to designer
  field :deposit_raised, type: Boolean, default: false
  # flag, apakah sudah pernah kirim data ke kissmetric
  field :log_to_kissmetric, type: Boolean, default: false

  # DEPRECATED, DELETED SOON
  field :client_paid_status, type: String, default: 'pending'
  field :request_designer_payment, type: Boolean, default: false
  field :payment_request_date, type: DateTime

  #                                                                       Relation
  # ==============================================================================
  has_one :agreement, as: :agreeable
  has_one :workspace, as: :workable
  belongs_to :winner_type
  belongs_to :contest
  belongs_to :entry

  belongs_to :designer, polymorphic: true
  belongs_to :client, polymorphic: true
  belongs_to :status, class_name: "WinnerStatus"

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_numericality_of :position

  #                                                                   Class Method
  # ==============================================================================
  class << self
  end

  #                                                                         Method
  # ==============================================================================
  def set_default_attributes

    # Set winner status default open for first winner
    if self.status.blank?
      if self.position == 1
        self.status = WinnerStatus.open # CH paid
      else
        self.status = WinnerStatus.pending # CH not paid yet
      end
    end

  end

  # Override ownerable
  # Check is current member is
  # winner owner
  # runner up owner
  def is_owned_by?(member = nil)
    return false if member.blank?
    if self.designer == member or self.client == member
      true
    else
      member.is_super_user? ? true : false
    end
  rescue
    false
  end

  # Statuses
  # Not paid yet
  def is_pending?
    self.status == WinnerStatus.pending
  end

  # Paid
  def is_open?
    self.status == WinnerStatus.open
  end

  # After workspace closed
  def is_closed?
    self.status == WinnerStatus.closed
  end

end
