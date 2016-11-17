class StoreItem
  include Mongoid::Document
  include Mongoid::Timestamps
  include Ownerable

  before_create do
    set_default_attributes
  end

  # Temporary id (for uploader)
  field :temp_id, type: String
  field :store_thumbnail
  field :store_preview
  field :store_master

  field :number, type: Float

  field :approved, type: Boolean # nil = Belum dicek, false = rejected, true = approved
  field :approved_date, type: DateTime
  field :approved_by

  field :available_license

  field :license # Yang didapat oleh desainer
  field :revision # Yang didapat oleh desainer

  field :admin_discount_value, type: Float, default: 0 # Ini dipakai kalau ada discount langsung dari admin, tidak bisa digabungkan dengan voucher discount biasa dan buyer tidak perlu masukkan voucher code. Valuenya misal IDR 90.000 untuk potongan sebesar 90.000, TIDAK simpan persentase. Persentase harus diconvert ke bentuk nominal.

  field :info

  field :download_counter_master, type: Integer, default: 0

  field :total_sales, type: Integer, default: 0 # Jumlah berapa kali multi license terbeli. Kalau orderan revisi berkali2 tidak dihitung. Single juga tetap dihitung 1 meskipun setelah itu tidak muncul lagi di store.


  # Edit by designer
  field :edit_request_date
  field :edit_store_thumbnail
  field :edit_store_preview
  field :edit_store_master
  field :edit_info
  field :edit_sub_category_id
  field :edit_industry_id
  field :edit_license
  field :edit_revision

  field :sub_category_id

  mount_uploader :store_thumbnail, StoreFileThumbnailUploader
  mount_uploader :store_preview, StoreFilePreviewUploader
  mount_uploader :store_master, StoreFileMasterUploader

  mount_uploader :edit_store_thumbnail, StoreFileThumbnailUploader
  mount_uploader :edit_store_preview, StoreFilePreviewUploader
  mount_uploader :edit_store_master, StoreFileMasterUploader

  #                                                                       Relation
  # ==============================================================================
  embeds_many :reject_reasons, class_name: "StoreRejectReason"
  belongs_to :owner, polymorphic: true
  belongs_to :industry
  belongs_to :status, class_name: "StoreItemStatus"


  #                                                                         Method
  # ==============================================================================
  def set_default_attributes
    self.status = StoreItemStatus.draft if self.status.blank?

    if self.number.blank? or self.number.zero?
      last_number = (StoreItem.desc(:number).first.present?) ? StoreItem.desc(:number).first.number : 0
      current_number = (last_number.present? and last_number > 0) ? last_number + 1 : 1
      self.number = current_number
    end
  end

  # Return sub_category
  def category
    category = StoreCategory.find_by("sub_categories._id" => self.sub_category_id)
    return category.present? ? category : nil
  end

  def sub_category
    return nil if category.blank?
    sub_category = category.sub_categories.find_by(:id => self.sub_category_id)
    return sub_category
  end


  # Return sell price
  def calculate_sell_price
    if self.license.present?
      license = self.license["fee"]["multi"]
      return license.to_f/40 * 100
    else
      return nil
    end
  end

  # Return prize
  def calculate_prize
    self.license.present? ? self.license["fee"]["multi"] : nil
  end

end
