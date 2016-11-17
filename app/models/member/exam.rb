# ================================================================================
# Part:
# Desc:
# ================================================================================
class Exam
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================
  EXAM_CATEGORY = %w(logo tshirt brochure web interior)

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_create :set_default_attributes

  #                                                                          Field
  # ==============================================================================
  field :attachment
  field :preview
  field :portfolios_link, type: String
  field :on_review, type: Boolean, default: false
  field :exam_number, type: Integer, default: 0
  field :approved, type: Boolean
  field :approved_at, type: DateTime
  # field :owner_email
  # field :owner_username

  field :category, type: String
  field :description, type: String

  mount_uploader :attachment, ExamUploader
  mount_uploader :preview, ExamPreviewUploader

  #                                                                       Relation
  # ==============================================================================
  belongs_to :owner, polymorphic: true

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  # TODO: there is a designer just submited portfolios_link without attachment
  # validates_presence_of :attachment
  # validates :attachment, file_size: { maximum: 700.kilobytes }, on: :create

  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  def self.send_unreviewed_exam_to_admin
    AdminMailerWorker.perform_async(perform: 'send_unreviewed_exam_to_admin')
  end

  def set_default_attributes
    self.exam_number = self.owner.exams.count + 1
  end
end
