class StoreFileThumbnailUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  self.fog_public = true

  configure do |config|
    config.remove_previously_stored_files_after_update = false
  end

  def extension_white_list
    %w(jpg jpeg png)
  end

  def store_dir
    "assets/media/stores/items/#{model.created_at.year}/#{model.created_at.month}/#{model.id}/"
  end

  def filename
    "thumbnail-#{secure_token(8)}.#{file.extension}" if original_filename.present?
  end

  version :thumb do
    process :resize_to_fit => [200,200]
  end

  protected
    def secure_token(length=16)
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
    end
end
