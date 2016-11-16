# encoding: utf-8

class EntryPreviewUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "assets/media/contest_detail/#{model.contest.created_at.year}/#{model.contest.created_at.month}/#{model.contest.permanent_title.parameterize}-#{model.contest.id}/preview/"
  end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    # %w(jpg jpeg png)
  end

  version :large do
    process :resize_to_fit => [700,500]
  end

  version :thumb do
    process :resize_to_fit => [205,160]
  end

  def filename
    "#{secure_token(10)}.#{file.extension}" if original_filename.present?
  end

  process :get_geometry

  # code to get geometry of the image
  def geometry
    @geometry
  end

  def get_geometry
    if (@file)
      img = ::Magick::Image::read(@file.file).first
      @geometry = [ img.columns, img.rows ]
    end
  end

  protected
    def secure_token(length=16)
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
    end
end
