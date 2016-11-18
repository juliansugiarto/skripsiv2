class ServicePhoto
  # require 'RMagick'
  extend Unscoped
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'service_photos'
  MAXIMUM_IN_SERVICE = 1

  belongs_to :service

  field :image
  field :name
  field :service_photo_id

  unscope :service

  mount_uploader :image, ServicePhotoUploader, :only => :create

  validates :image, :presence => true, :on => :create
  validates :service_photo_id, :presence => true

	validates :image, file_size: {
		maximum: 10.megabytes
	}, on: :create
  
  validate :check_maximum_in_service

  def check_maximum_in_service
    if ServicePhoto.where(service_photo_id: self.service_photo_id).count >= MAXIMUM_IN_SERVICE
      errors.add(:maximum, I18n.t('general.maximum_reached', :maximum => MAXIMUM_IN_SERVICE))
    end
  end


  def self.delete_orphan
    ServiceAttachment.where(:service_id => nil, :created_at.lte => 7.days.ago).each do |ca|
      ca.destroy
    end
  end

end
