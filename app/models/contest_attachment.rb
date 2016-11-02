# ================================================================================
# Part:
# Desc:
# ================================================================================
class ContestAttachment
  include Mongoid::Document
  include Mongoid::Timestamps
  require 'rmagick'


  #                                                                       Constant
  # ==============================================================================
  MAXIMUM_IN_CONTEST = 15


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================
  field :contest_attachment_group_id
  field :image
  field :name, type: String
  mount_uploader :image, ContestAttachmentUploader, only: :create


  #                                                                       Relation
  # ==============================================================================
  belongs_to :contest


  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates :image, presence: true, on: :create
  validates :image, file_size: { maximum: 30.megabytes }, on: :create
  validate :check_maximum_in_contest


  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  def check_maximum_in_contest
    if self.contest.blank?
      if ContestAttachment.where(contest_attachment_group_id: self.contest_attachment_group_id).count >= MAXIMUM_IN_CONTEST
        errors.add(:maximum, I18n.t('contest_attachment.create.error.maximum_reached', maximum: MAXIMUM_IN_CONTEST))
      end
    else
      if self.contest.attachments.count >= MAXIMUM_IN_CONTEST
        errors.add(:maximum, I18n.t('contest_attachment.create.error.maximum_reached', maximum: MAXIMUM_IN_CONTEST))
      end
    end
  end

  def thumb_image

    if !self.image_type?
      "/assets/preview-not-available.jpg"
    elsif SystemConfiguration.using_s3?
      self.image_url(:thumb).to_s
    else
      if File.file?(Rails.root.to_s + "/public" + self.image.url(:thumb).to_s)
        self.image.url(:thumb)
      else
        "/assets/preview-not-available.jpg"
      end
    end
  end

  def image_type?
    image_ext = ['.png', '.gif', '.jpg', '.jpeg', '.bmp', '.tiff']
    image_ext.each do |ext|
      return true if self.name.include?(ext)
    end
    return false
  end

  def contest_attachment_group_id
    if !self.contest.blank?
      self.contest.contest_attachment_group_id
    else
      self[:contest_attachment_group_id]
    end
  end

  def self.delete_orphan
    ContestAttachment.where(contest_id: nil, :created_at.lte => 7.days.ago).each do |ca|
      ca.destroy
    end
  end

  # ==============================================================================
  # PLACE ALL DELETED, MIGRATED, RENAMED OBJECT HERE
  # ==============================================================================
end
