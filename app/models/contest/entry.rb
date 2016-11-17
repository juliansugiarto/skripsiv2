# ================================================================================
# Part:
# Desc:
# ================================================================================
class Entry
  include Mongoid::Document
  include Mongoid::Timestamps
  require 'rmagick'
  include Ownerable

  #                                                                          Index
  # ==============================================================================
  index({contest_id: 1})
  index({owner_id: 1})

  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_create do
    set_contest_counter_id
  end

  before_save do
    set_contest_counter_id
  end

  #                                                                          Field
  # ==============================================================================
  field :image
  field :preview
  field :naming, type: String
  field :source, type: Array, default: []
  field :description, type: String
  field :eliminated, type: Boolean, default: false
  field :rating, type: Integer, default: 0
  field :contest_counter_id, type: Integer, default: 0
  field :contest_counter_id_old, type: Integer, default: 0
  field :likes_count, type: Integer, default: 0
  field :views_count, type: Integer, default: 0
  # this field not implemented yet !!
  field :withdrawed, type: Boolean, default: false

  #                                                                       Uploader
  # ==============================================================================
  mount_uploader :image, EntryUploader
  mount_uploader :preview, EntryPreviewUploader


  #                                                                       Relation
  # ==============================================================================
  # Owner as polymorphic, in case in the future not only member can upload design
  belongs_to :owner, polymorphic: true
  belongs_to :contest
  has_one :winner
  has_many :comments, as: :commentable
  has_many :likes, as: :likeable

  belongs_to :revised_from, polymorphic: true, class_name: "Entry"

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :image, if: lambda {|o| o.contest.category.name != "Naming/Tagline"}, on: :create
  validates_presence_of :naming, if: lambda {|o| o.contest.category.name == "Naming/Tagline"}
  # validates :image, file_size: {
  #   maximum: Rails.env == 'test' ? 0 : SystemConfiguration.maximum_contest_detail_attachment_file_size.to_i
  # }, if: lambda {|o| o.contest.category.name != "Naming/Tagline"}, on: :create

  validate :validate_image_dimension
  validate :image_size_validation, :if => "image?"
  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  def is_eliminated?
    self.eliminated
  end

  def is_withdrawed?
    self.withdrawed
  end

  def is_winner?
    Winner.find_by(entry: self, position: 1).present?
  end

  def is_runner_up?
    Winner.find_by(entry: self, :position.gt => 1).present?
  end

  def validate_image_dimension
    geometry = self.image.geometry
    if (! geometry.nil?)
      width = geometry[0]
      height = geometry[1]
      if width < 100 or height < 100
        errors.add :base, I18n.t("contest_detail.upload.errors.minimum_dimension")
      end

      # Disable this validation
      # # check aspect ratio
      # aspect_ratio = (width > height) ? (width * 1.0 / height) : (height * 1.0 / width)
      # if aspect_ratio > 5
      #   errors.add :base, I18n.t("contest_detail.upload.errors.aspect_ratio")
      # end
    end
  end

  def image_size_validation
    if image.size > 500.kilobytes
      errors.add :base, I18n.t("contest_detail.upload.errors.minimum_dimension")
    end
  end

  def set_contest_counter_id
    if self.contest_counter_id.blank? or self.contest_counter_id.zero?
      entries = Entry.where(contest: self.contest).desc(:contest_counter_id)
      last_entry = entries.first
      if last_entry.blank?
        self.contest_counter_id = 1
      else
        self.contest_counter_id = last_entry.contest_counter_id + 1
      end
    end
  end

  # ==============================================================================
  # PLACE ALL DELETED, MIGRATED, RENAMED OBJECT HERE
  # ==============================================================================

end
