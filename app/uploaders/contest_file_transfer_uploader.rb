# encoding: utf-8

class ContestFileTransferUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  # Choose what kind of storage to use for this uploader
  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "assets/media/file_transfer/#{model.created_at.year}/#{model.created_at.month}/#{model.workspace.id}/"
  end



  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

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


  # Override the filename of the uploaded files:
  # Avoid using model.id or version_name here, see uploader/store.rb for details.
  # def filename
  #   "something.jpg" if original_filename
  # end

  def filename
    if original_filename.present?
      arr = original_filename.split(".")
      arr.pop # remove last element of the array instantly
      final_name = arr.join(".")
      "#{final_name}-#{secure_token(10)}.#{file.extension}"
    end
  end

  protected
    def secure_token(length=16)
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
    end
end
