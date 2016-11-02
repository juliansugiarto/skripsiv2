# ================================================================================
# Part: Notification
# Desc: Notification for member and admin
# ================================================================================
class Notification
  include Mongoid::Document
  include Mongoid::Timestamps
  include UtilityHelper
  include Rails.application.routes.url_helpers

  #                                                                       Constant
  # ==============================================================================


  #                                                                          Index
  # ==============================================================================
  index({notify_id: 1})
  index({contest_id: 1})
  index({entry_id: 1})

  # DEPRECATED, DELETED SOON
  index({member_id: 1})


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  after_create :notify


  #                                                                          Field
  # ==============================================================================
  # Notification purpose for something, eg: comment, like, etc
  # More specific than _type
  field :purpose

  field :title
  field :description
  field :read, type: Boolean, default: false


  # Fields
  field :counter, type: Integer, default: 1
  field :email_sent, type: Boolean, default: false

  # DEPRECATED, DELETED SOON
  # From ol data, need to migrate to new data structure
  field :type # Old field
  field :comment_id
  field :contest_detail_id
  field :member_id

  #                                                                       Relation
  # ==============================================================================
  belongs_to :notified, polymorphic: true # Person who notified
  belongs_to :contest
  belongs_to :entry

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================

  def self.set_notifications_to_read(notification_id)
    n = Notification.find notification_id
    n.update_attribute(:read, true)
  end

  #                                                                         Method
  # ==============================================================================
  private
  def notify
    # TODO:
    # Push notify user
  end

end
