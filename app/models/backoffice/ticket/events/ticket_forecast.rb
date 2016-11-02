# ================================================================================
# Part:
# Desc:
# Inquiry ticket solve or auto solve set active to false
# Unpaid ticket auto add value by contest price
# ================================================================================
class TicketForecast < TicketEvent

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================

  #                                                                       Callback
  # ==============================================================================
  before_create do
    set_default_attributes
  end

  #                                                                          Field
  # ==============================================================================
  field :value, type: Integer
  # field :active, type: Boolean, default: true
  # field :edited, type: Boolean, default: false

  #                                                                       Relation
  # ==============================================================================
  belongs_to :status, class_name: "ForecastStatus" # Default to active

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :value

  #                                                                   Class Method
  # ==============================================================================

  #                                                                         Method
  # ==============================================================================
  def set_default_attributes
    self.status = ForecastStatus.active if self.status.blank?
  end
end
