class ExamPreviewUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  ## to generate expired url
  self.fog_public = false
  self.fog_authenticated_url_expiration = 120 # time in second

  def extension_white_list
    # %w(jpg jpeg png)
  end

  def store_dir
    "assets/media/#{model.class.to_s.underscore}/preview/"
  end

  def filename
    if original_filename.present? and file.extension.present?
      "#{secure_token(8)}.#{file.extension}"
    else
      "#{secure_token(8)}.jpg"
    end
  end

  # version :thumb do
  #   process :resize_to_fit => [100,100]
  # end
  #
  # version :large do
  #   process :resize_to_fit => [500,500]
  # end

  protected
    def secure_token(length=16)
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
    end
end
