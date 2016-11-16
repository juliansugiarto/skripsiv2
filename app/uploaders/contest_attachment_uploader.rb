# encoding: utf-8

class ContestAttachmentUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  # Override the directory where uploaded files will be stored.
  # This is a sensible default for uploaders that are meant to be mounted:
  def store_dir
    "assets/media/#{model.class.to_s.underscore}/#{model.contest_attachment_group_id}/"
  end

  version :large, :if => :image? do
    process :resize_to_fit => [700,500]
  end

  version :thumb, :if => :image? do
    process :resize_to_fit => [200,200]
  end

  def filename
    "#{secure_token(10)}.#{file.extension}" if original_filename.present?
  end

  def image?(new_file)
    new_file.content_type.include? 'image'
  end

  protected

    def secure_token(length=16)
      var = :"@#{mounted_as}_secure_token"
      model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
    end

end
