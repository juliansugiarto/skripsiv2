# ================================================================================
# Part:
# Desc:
# ================================================================================
class Reputation
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :grade
  field :rank
  field :satisfaction
  field :vote
  field :fame

  field :total_point, type: Integer, default: 0
  field :total_report, type: Integer, default: 0
  field :point, type: Integer, default: 0

  field :message
  field :action
  field :first_record, type: Boolean, default: false

  #                                                                       Relation
  # ==============================================================================
  belongs_to :member
  belongs_to :from, polymorphic: true # TODO: Change this
  belongs_to :reputationable, polymorphic: true

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :message

  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================

end
