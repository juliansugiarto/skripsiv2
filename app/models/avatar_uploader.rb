# encoding: utf-8

class AvatarUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    # "uploads/#{model.class.to_s.underscore}/#{mounted_as}/#{model.id}"
    "assets/media/avatar/#{model.username}"
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  def default_url
    # "/images/fallback/" + [version_name, "default.png"].compact.join('_')
    # set sama semua
    if version_name == "thumb"
      "https://sribu-sg.s3.amazonaws.com/assets/media/avatar/avatar-default.png"
    elsif version_name == "normal"
      "https://sribu-sg.s3.amazonaws.com/assets/media/avatar/avatar-default.png"
    else
      "https://sribu-sg.s3.amazonaws.com/assets/media/avatar/avatar-default.png"
    end
  end

  # Process files as they are uploaded:
  # process :scale => [200, 300]
  #
  # def scale(width, height)
  #   # do something
  # end

  # Create different versions of your uploaded files:
  # version :thumb do
  #   process :scale => [50, 50]
  # end

  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  # def extension_white_list
  #   %w(jpg jpeg gif png)
  # end

  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  def extension_white_list
    %w(jpg jpeg png)
  end

  version :thumb do
    process :resize_to_fit => [32,32]
  end

  version :normal do
    process :resize_to_fit => [140,140]
  end

  version :large do
    process :resize_to_fit => [250,250]
  end

end
