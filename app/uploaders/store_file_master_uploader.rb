class StoreFileMasterUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  self.fog_public = false
  self.fog_authenticated_url_expiration = SystemConfiguration.file_download_expires #second

  configure do |config|
    config.remove_previously_stored_files_after_update = false
  end

  def extension_white_list
    %w(zip rar ai psd)
  end

  def store_dir
    "assets/media/stores/items/#{model.created_at.year}/#{model.created_at.month}/#{model.id}/"
  end

  def filename
    "master-#{secure_token(8)}.#{file.extension}" if original_filename.present?
  end

  # version :thumb do
  #   process :resize_to_fit => [100,100]
  # end

  # version :large do
  #   process :resize_to_fit => [500,500]
  # end

  protected
    def secure_token(length=16)
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
    end
end
