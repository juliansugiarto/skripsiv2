class PaymentConfirmationUploader < CarrierWave::Uploader::Base
  include CarrierWave::RMagick

  def store_dir
    "assets/media/#{model.class.to_s.underscore}/#{model.created_at.year}/#{model.created_at.month}/"
  end

  def default_url
    "https://sribu-sg.s3.amazonaws.com/assets/media/contest/no-attachment.jpg"
  end

  def extension_white_list
    %w(jpg jpeg png gif pdf doc docx xls)
  end

  def filename
    "#{secure_token(4)}.#{file.extension}" if original_filename.present?
  end

  protected
  def secure_token(length=16)
    var = :"@#{mounted_as}_secure_token"
    model.instance_variable_get(var) or model.instance_variable_set(var, SecureRandom.hex(length/2))
  end
end
