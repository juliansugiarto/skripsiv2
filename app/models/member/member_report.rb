class MemberReport

  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                          Field
  # ==============================================================================
  field :comment, type: String
  field :link, type: String
  field :status, type: String
  field :report_user, type: Boolean, default: false


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  belongs_to :reported, polymorphic: true
  belongs_to :reporter, polymorphic: true
  belongs_to :reference, polymorphic: true


  #                                                                     Validation
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================


  #                                                                Instance Method
  # ==============================================================================


end
