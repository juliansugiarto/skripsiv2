# ================================================================================
# Part:
# Desc:
# ================================================================================
class Ticket
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================
  TYPES = %w( LeadTicket RegisterTicket ComboTicket PotentialTicket
              ContestUnpaidTicket StoreUnpaidTicket
              PackageUpgradeTicket FeatureUpgradeTicket RunnerUpTicket
              CancelTicket FileTransferTicket WinnerPendingTicket)
  COMBINATION_TYPES = %w( InquiryTicket UnpaidTicket UpgradeTicket HappinessTicket)
  INQUIRY_TYPES = %w( LeadTicket RegisterTicket ComboTicket PotentialTicket)
  UNPAID_TYPES = %w( ContestUnpaidTicket StoreUnpaidTicket)
  UPGRADE_TYPES = %w( PackageUpgradeTicket FeatureUpgradeTicket RunnerUpTicket)
  HAPPINESS_TYPES = %w( CancelTicket FileTransferTicket WinnerPendingTicket)

  #                                                                  Attr Accessor
  # ==============================================================================

  #                                                                       Callback
  # ==============================================================================
  before_create do
    set_default_attributes
  end

  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :number, type: Integer
  field :active, type: Boolean, default: true

  #                   ``                                                    Relation
  # ==============================================================================
  belongs_to :created_for, polymorphic: true # Member / Lead
  belongs_to :assigned_to, class_name: "User", inverse_of: :workers
  belongs_to :assigned_by, class_name: "User", inverse_of: :requesters
  belongs_to :status, class_name: "TicketStatus" # Default to open
  belongs_to :priority, class_name: "TicketPriority" #Default to warm

  has_many :events, class_name: "TicketEvent" # Follow ups, Forecast here

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :created_for

  #                                                                   Class Method
  # ==============================================================================
  class << self

    def types
      TYPES
    end

    def combination_types
      COMBINATION_TYPES
    end

    def inquiry_types
      INQUIRY_TYPES
    end

    def unpaid_types
      UNPAID_TYPES
    end

    def upgrade_types
      UPGRADE_TYPES
    end

    def happiness_types
      HAPPINESS_TYPES
    end

    def with_contest_types
      TYPES - INQUIRY_TYPES - ['StoreUnpaidTicket']
    end

    def ticket_group_check(ticket_type)
      if INQUIRY_TYPES.include?(ticket_type)
        return 'inquiry_group'
      elsif UNPAID_TYPES.include?(ticket_type)
        return 'unpaid_group'
      elsif UPGRADE_TYPES.include?(ticket_type)
        return 'upgrade_group'
      elsif HAPPINESS_TYPES.include?(ticket_type)
        return 'happiness_group'
      else
        return 'unknown_group'
      end
    end

  end

  scope :lead, lambda { where(_type: 'LeadTicket') }
  scope :register, lambda { where(_type: 'RegisterTicket') }
  scope :combo, lambda { where(_type: 'ComboTicket') }
  scope :potential, lambda { where(_type: 'PotentialTicket') }
  scope :inquiry, lambda { any_in(_type: ['LeadTicket', 'RegisterTicket', 'ComboTicket', 'PotentialTicket'])}
  scope :contest_unpaid, lambda { where(_type: 'ContestUnpaidTicket') }
  scope :store_unpaid, lambda { where(_type: 'StoreUnpaidTicket') }
  scope :unpaid, lambda { any_in(_type: ['ContestUnpaidTicket', 'StoreUnpaidTicket']) }
  scope :package_upgrade, lambda {where(_type: 'PackageUpgradeTicket') }
  scope :feature_upgrade, lambda {where(_type: 'FeatureUpgradeTicket') }
  scope :runnerup_upgrade, lambda {where(_type: 'RunnerUpTicket') }
  scope :upgrade, lambda { any_in(_type: ['PackageUpgradeTicket', 'FeatureUpgradeTicket', 'RunnerUpTicket'])}
  scope :cancel, lambda {where(_type: 'CancelTicket') }
  scope :file_transfer, lambda {where(_type: 'FileTransferTicket') }
  scope :winner_pending, lambda {where(_type: 'WinnerPendingTicket') }
  scope :happiness, lambda { any_in(_type: ['CancelTicket', 'FileTransferTicket', 'WinnerPendingTicket'])}

  #                                                                         Method
  # ==============================================================================

  def set_default_attributes
    self.status = TicketStatus.open if self.status.blank?
    self.priority = TicketPriority.warm if self.priority.blank?
    self.number = Ticket.desc(:created_at).first.number.to_i + 1
  end
end
