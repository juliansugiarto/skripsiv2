class PackageOrderAttachment
  # require 'RMagick'
  
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'package_order_attachments'
  MAXIMUM_IN_PACKAGE_ORDER_APPLICATION = 15

  field :image
  field :name
  field :package_order_attachment_group_id

  belongs_to :package_order

  mount_uploader :image, PackageOrderAttachmentUploader, :only => :create

  validates :image, :presence => true, :on => :create

  validates :image, file_size: {
    maximum: 10.megabytes
  }, on: :create
  
  validate :check_maximum_in_package_order

  index({package_order_attachment_group_id: 1})

  def check_maximum_in_package_order
    if PackageOrderAttachment.where(package_order_attachment_group_id: self.package_order_attachment_group_id).count >= MAXIMUM_IN_PACKAGE_ORDER_APPLICATION
      errors.add(:maximum, I18n.t('general.maximum_reached', :maximum => MAXIMUM_IN_PACKAGE_ORDER_APPLICATION))
    end
  end


  def self.delete_orphan
    PackageOrderAttachment.where(:package_order_id => nil, :created_at.lte => 7.days.ago).each do |ca|
      ca.destroy
    end
  end

end
