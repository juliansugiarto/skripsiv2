# ================================================================================
# Part:
# Desc:
# ================================================================================
class WorkspaceEventContestFileTransfer < WorkspaceEvent
  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================
  before_destroy :before_destroy_callback

  #                                                                          Field
  # ==============================================================================
  field :url
  field :old_file
  field :attachment
  mount_uploader :attachment, ContestFileTransferUploader

  #                                                                       Relation
  # ==============================================================================


  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================
  validates_presence_of :attachment

  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================
  def filename_sanitize_ext(filename)
    filename = filename.split('.')
    ext = filename.delete(filename.last)
    random = SecureRandom.hex(2)
    return filename.join().parameterize + "-#{random}.#{ext}"
  end


  def store_attachment(attachment)
    directory = mkdir
    contest = self.agreement.winner.contest_detail.contest
    now = contest.created_at
    permanent_title = contest.permanent_title
    if File.directory?(directory)
      attachment_name = filename_sanitize_ext( attachment.original_filename )
      FileUtils.cp(attachment.path, "#{directory}#{attachment_name}")
      self.file = "/assets/media/file_transfer/#{now.year}/#{now.month}/#{permanent_title.parameterize}-#{contest.id}/#{attachment_name}"
    end
  end

  def append_attachment(file, file_type)
    extension = file_type
    directory = mkdir
    contest = self.agreement.winner.contest_detail.contest
    now = contest.created_at
    permanent_title = contest.permanent_title
    if File.directory? directory
      attachment_name = Digest::MD5::hexdigest(file.to_s + Time.now.to_s)
      FileUtils.cp(file, "#{directory}#{attachment_name}.#{extension}")
      self.file = "/assets/media/file_transfer/#{now.year}/#{now.month}/#{permanent_title.parameterize}-#{contest.id}/#{attachment_name}.#{extension}"
    end
  end

  def get_attachment
    file_name = self.file.split("/").last
    contest_detail = self.agreement.winner.contest_detail
    if contest_detail.present? && contest_detail.contest.present?
      contest = self.agreement.winner.contest_detail.contest
      now = contest.created_at
      permanent_title = contest.permanent_title
      root_store_directory + "/#{now.year}/#{now.month}/#{permanent_title.parameterize}-#{contest.id}/#{file_name}"
    else
      root_store_directory
    end
  end

  private
  def mkdir
    contest = self.agreement.winner.contest_detail.contest
    now = contest.created_at
    permanent_title = contest.permanent_title
    directory = "#{root_store_directory}#{now.year}/#{now.month}/#{permanent_title.parameterize}-#{contest.id}/"
    FileUtils.mkdir_p directory unless File.directory? directory
    directory
  end

  def root_store_directory
    Rails.root.to_s + "/public/assets/media/file_transfer/"
  end

  def before_destroy_callback
    attachment = get_attachment
    FileUtils.remove attachment if File.file? attachment
  end
end
