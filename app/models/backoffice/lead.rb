# ================================================================================
# Part:
# Desc:
# ================================================================================
class Lead
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :phone_number, type: String
  field :email, type: String
  field :note, type: String               # Keterangan untuk kebutuhan desain
  field :budget, type: Integer
  field :pic, type: String
  field :how_do_you_know, type: String
  # User.username, kalau import maka tertulis 'administrator', sedangkan kalau dari user dari front end tertulis 'front-end'
  field :created_by, type: String
  field :utm_source, type: String
  field :utm_medium, type: String
  field :utm_campaign, type: String
  field :utm_term, type: String
  field :location, type: String
  field :cancel, type: Boolean, default: false

  # TODO: implement package combo lead
  field :package, type: String # Used for leads from combo package request

  # DEPRECATED, DELETED SOON
  field :assign_type, type: String
  field :assign_reminder, type: DateTime

  #                                                                       Relation
  # ==============================================================================
  belongs_to :category
  belongs_to :upline, :class_name => "Member", :inverse_of => :downlines
  has_many :tickets, as: :created_for
  has_many :ticket_follow_up, as: :target

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :name, :phone_number

  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================

end
