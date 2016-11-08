# ================================================================================
# Part:
# Desc:
# ================================================================================
class MetricDashboard
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :data_date, type: Date
  field :designer_approved, type: Integer, default: 0
  field :ch_sign_up, type: Integer, default: 0
  field :subscribers, type: Integer, default: 0
  field :contest_created, type: Integer, default: 0
  field :sales_generated, type: Integer, default: 0
  field :profit_generated, type: Integer, default: 0
  field :contest_approved, type: Integer, default: 0

  #                                                                       Relation
  # ==============================================================================


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
