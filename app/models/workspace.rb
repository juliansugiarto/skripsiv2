# ================================================================================
# Part:
# Desc:
# ================================================================================
class Workspace
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ownerable

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_create do
    set_default_attributes
  end

  before_save do
    set_default_attributes
  end

  #                                                                          Field
  # ==============================================================================
  # Flag if prize was raised to designer
  field :deposit_raised, type: Boolean, default: false
  field :step

  #                                                                       Relation
  # ==============================================================================
  belongs_to :workable, polymorphic: true
  belongs_to :client, class_name: "Member", polymorphic: true
  belongs_to :designer, class_name: "Member", polymorphic: true
  belongs_to :status, class_name: "WorkspaceStatus"
  embeds_many :events, class_name: "WorkspaceEvent"

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :workable

  #                                                                   Class Method
  # ==============================================================================
  class << self
  end

  #                                                                         Method
  # ==============================================================================
  # Check is current member is workspace participant or not
  def is_participant?(member = nil)
    raise if member.blank?
    if member.is_contest_holder?
      self.client == member
    elsif member.is_designer?
      self.designer == member
    else
      false
    end
  rescue
    false
  end

  # Override ownerable method
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

  private
  def set_default_attributes
    self.status = WorkspaceStatus.open if self.status.blank?
  end

end
