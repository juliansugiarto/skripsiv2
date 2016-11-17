# ================================================================================
# Part:
# Desc:
# ================================================================================
class Participation
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_save do
    set_slot
  end

  #                                                                          Field
  # ==============================================================================
  field :title, type: String
  field :description, type: String
  field :active, type: Boolean, default: true
  field :slot, type: Integer, default: 0 # Slot design for designer
  field :request_slot, type: Boolean, default: false # Flag if designer has been request a slot

  #                                                                       Relation
  # ==============================================================================
  belongs_to :participant, polymorphic: true # Member
  belongs_to :contest

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
  # Set designer slot based on contest package
  def set_slot
    c = self.contest
    p = c.package
    m = self.participant

    # Set slot if still zero
    if self.slot == 0
      self.slot = c.max_slot
    end
  end

end
