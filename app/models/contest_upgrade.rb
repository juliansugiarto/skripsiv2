# ================================================================================
# Part:
# Desc:
# Save history of contest upgrade
# ================================================================================
class ContestUpgrade
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_create do
    self.status = UpgradeStatus.requested unless self.status.present?
  end

  #                                                                          Field
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  belongs_to :status, class_name: "UpgradeStatus"
  belongs_to :contest
  has_one :ticket # UpgradeTicket

  belongs_to :old_package, polymorphic: true # old package
  belongs_to :new_package, polymorphic: true # new package

  has_and_belongs_to_many :features # upgrade features

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================

  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================

end
