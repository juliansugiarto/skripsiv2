class MessageAttachmentUploader < CarrierWave::Uploader::Base

  include CarrierWave::RMagick

  def extension_white_list
    %w(jpg jpeg png zip rar ai psd cdr doc docx ppt pptx xls xlsx pdf)
  end

  def store_dir
    "assets/media/stores/workspaces/#{model.created_at.year}/#{model.created_at.month}/#{model.workspace.id}/"
  end

  def filename
    if original_filename.present?
      arr = original_filename.split(".")
      arr.pop # remove last element of the array instantly
      final_name = arr.join(".")
      "#{final_name}-#{secure_token(10)}.#{file.extension}"
    end
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
