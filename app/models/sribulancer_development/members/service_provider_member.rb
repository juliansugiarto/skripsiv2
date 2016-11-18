class ServiceProviderMember < MemberLancer
  extend Unscoped
  include FullErrorMessages

  CNAME = 'service_provider'

  belongs_to :company_category, class_name: "OfflineGroupCategory"
  has_and_belongs_to_many :company_area_of_service, class_name: "Location"
  has_many :service_provider_reviews

  field :verified, type: Boolean, default: false
  field :email_notif_new_task, type: Boolean, default: true

  field :company_name
  field :company_profile
  field :company_contact_number
  field :company_website
  field :company_address
  field :company_npwp
  field :company_facebook
  field :company_twitter
  field :company_bio
  field :company_employee
  field :name, as: :pic_name
  field :pic_role
  field :contact_number, as: :pic_contact_number
  field :pic_photo

  has_many :task_applications, :foreign_key => :member_id

  has_and_belongs_to_many :company_sub_categories, class_name: "OfflineCategory"

  mount_uploader :company_photo, MemberPhotoUploader

  after_create :send_registration_success

  def reviews_avg
    number_with_precision(self.member_reviews.avg(:rating), precision: 2)
  end

  def rating
    self.member_reviews.avg(:rating)
  end
  
  def member_reviews
    service_provider_reviews
  end

  def send_thank_you_registering_email
    ServiceProviderMailer.send_thank_you_registering_email(self).deliver
  end

  def send_account_verified_email
    ServiceProviderMailer.send_account_verified_email(self).deliver
  end

  def push_to_cakemail
    # CakemailWorker.perform_async(perform: :new_subscriber, email: self.email, name: self.name, phone: self.country.phone_code + self.contact_number, contact_list: "reg_web_service_provider_#{self.locale.to_s}")
  end

  def last_order(obj)
      task_application = TaskApplication.find_by(member: self, task: obj)
      return nil if task_application.blank? or task_application.orders.blank?
      task_application.orders.created_at_desc.first
  end

  def last_hired(obj)

    if obj.class == Task
      last_order = last_order(obj)

      if last_order
        return last_order.created_at
      else
        return nil
      end
    else
      return nil
    end

  end

  def company_area_of_service_tokens=(arg)
    area_list = Array.new
    arg.split(',').each do |area_id|
      al = Location.find(area_id)
      area_list << al.id if al.present?
    end
    self.company_area_of_service_ids = area_list
  end

  def company_area_of_service_tokens
    self.company_area_of_service.collect { |al| "#{al.id}:#{al.name}" }.join(',')
  end

  def self.company_employee_select_list
    ["0 - 50 employees", "51 - 100 employees", "101 - 500 employees", "500+"]
  end

  def workspaces
    task_applications_id = self.task_applications.collect &:id
    task_orders_id = TaskOrder.any_in(task_application_id: task_applications_id).collect &:id

    TaskWorkspace.any_in(task_order_id: task_orders_id) 
  end

  private

  def notify_km
    KissmetricsWorker.perform_async(perform: :service_provider_signup, identity: self.email, properties: {})
  end
end
