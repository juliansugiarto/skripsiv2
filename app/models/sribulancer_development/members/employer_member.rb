# represent member for employer
class EmployerMember < MemberLancer
  extend Unscoped

  after_create :push_to_cakemail, :push_to_infusionsoft

  CNAME = 'employer'

  belongs_to :industry

  has_many :jobs, :foreign_key => :member_id
  has_many :tasks, :foreign_key => :member_id
  has_many :recruitments, :foreign_key => :member_id
  has_many :member_preferences, :foreign_key => :member_id
  has_many :package_orders, :foreign_key => :owner_id

  has_many :employer_reviews
  embeds_many :reviews

  scope :created_between, ->(start_period, end_period) { where(:created_at.gt => start_period, :created_at.lte => end_period) }

  unscope :jobs
  unscope :tasks

  # Company Default. Pertama kali buat recruitment, maka akan tersimpan juga di table member ini. 
  field :company_name
  field :company_profile
  field :company_overview
  field :potencial, type: Boolean, default: false

  field :company_name_permanent, default: "" # Pertama kali company_name kalau terisi maka akan tersimpan juga di company_name_permanent dalam bentuk parameterize. Ini dipakai untuk url /company/[company_name_permanent]. Data TIDAK DAPAT berubah.

  field :email_notif_daily_recap_job_freelance, type: Boolean, default: true # Used by employers to receive daily updates (new freelancers) on their job

  def reviews_avg
    number_with_precision(self.member_reviews.avg(:rating), precision: 1)
  end

  def member_reviews
    employer_reviews
  end

  # TODO:
  # We have 2 kind of workspaces now.
  # Service and Job
  # We need to separate this function.
  # Or maybe we can append service workspaces to this function.
  def workspaces(params)
    params[:status] = 'all' if params[:status].blank?
    params[:type] = 'all' if params[:type].blank?

    service_orders_id = ServiceOrder.any_in(employer_id: self.id).collect &:id
    jobs_id = self.jobs.unscoped.collect &:id
    job_orders_id = JobOrder.any_in(job_id: jobs_id).collect &:id
    package_orders_id = PackageOrder.where(employer: self).collect &:id
    tasks_id = self.tasks.unscoped.collect &:id
    task_orders_id = TaskOrder.any_in(task_id: tasks_id).collect &:id

    if params[:job].present?
      job_orders_id = JobOrder.any_in(job_id: params[:job]).collect &:id
      params[:type] = "job"
    elsif params[:task].present?
      task_orders_id = TaskOrder.any_in(task_id: params[:task]).collect &:id
      params[:type] = "task"
    elsif params[:service].present?
      service_orders_id = params[:service]
      params[:type] = "service"
    elsif params[:job_applicant].present?
      job_orders_id = JobOrder.where(job_application_id: params[:job_applicant]).collect &:id
      params[:type] = "job" 
    elsif params[:task_applicant].present?
      task_orders_id = TaskOrder.where(task_application_id: params[:task_applicant]).collect &:id
      params[:type] = "task"        
    end


    case params[:status]
    when "all"
      job_workspace = JobWorkspace.any_in(job_order_id: job_orders_id)
      service_workspace = ServiceWorkspace.any_in(service_order_id: service_orders_id)     
      task_workspace = TaskWorkspace.any_in(task_order_id: task_orders_id)
      package_workspace = PackageWorkspace.any_in(package_order_id: package_orders_id)

    when "on_progress"
      job_workspace = JobWorkspace.any_in(job_order_id: job_orders_id).where( :"events._type" => {"$nin" => ["AdminCanceledEvent", "AdminRefundedEvent", "EmployerClosedJobEvent", "AdminReleasedPayoutEvent", "FreelancerRequestedPayoutEvent"]} )
      service_workspace = ServiceWorkspace.any_in(service_order_id: service_orders_id).any_in(service_order_id: service_orders_id).where( :"events._type" => {"$nin" => ["AdminCanceledEvent", "AdminRefundedEvent", "EmployerClosedJobEvent", "AdminReleasedPayoutEvent", "FreelancerRequestedPayoutEvent"]})
      task_workspace = TaskWorkspace.any_in(task_order_id: task_orders_id).where( :"events._type" => {"$nin" => ["AdminCanceledEvent", "AdminRefundedEvent", "EmployerClosedJobEvent", "AdminReleasedPayoutEvent", "FreelancerRequestedPayoutEvent"]} )
      package_workspace = PackageWorkspace.any_in(package_order_id: package_orders_id).where( :"events._type" => {"$nin" => ["AdminCanceledEvent", "AdminRefundedEvent", "EmployerClosedJobEvent", "AdminReleasedPayoutEvent", "FreelancerRequestedPayoutEvent"]} )

    when "completed"
      job_workspace = JobWorkspace.any_in(job_order_id: job_orders_id).where( :"events._type" => { "$in" => ["EmployerClosedJobEvent", "AdminReleasedPayoutEvent"] } )
      service_workspace = ServiceWorkspace.any_in(service_order_id: service_orders_id).where( :"events._type" => { "$in" => ["EmployerClosedJobEvent", "AdminReleasedPayoutEvent"] } )
      task_workspace = TaskWorkspace.any_in(task_order_id: task_orders_id).where( :"events._type" => { "$in" => ["EmployerClosedJobEvent", "AdminReleasedPayoutEvent"] } )
      package_workspace = PackageWorkspace.any_in(package_order_id: package_orders_id).where( :"events._type" => { "$in" => ["EmployerClosedJobEvent", "AdminReleasedPayoutEvent"] } )
    
    when "cancelled"
      job_workspace = JobWorkspace.any_in(job_order_id: job_orders_id).where(:"events._type" => "AdminCanceledEvent")
      task_workspace = TaskWorkspace.any_in(task_order_id: task_orders_id).where(:"events._type" => "AdminCanceledEvent")
      service_workspace = ServiceWorkspace.any_in(service_order_id: service_orders_id).where(:"events._type" => "AdminCanceledEvent")
      package_workspace = PackageWorkspace.any_in(package_order_id: package_orders_id).where(:"events._type" => "AdminCanceledEvent")
      
    when "refunded"
      job_workspace = JobWorkspace.any_in(job_order_id: job_orders_id).where(:"events._type" => "AdminRefundedEvent")
      task_workspace = TaskWorkspace.any_in(task_order_id: task_orders_id).where(:"events._type" => "AdminRefundedEvent")
      service_workspace = ServiceWorkspace.any_in(service_order_id: service_orders_id).where(:"events._type" => "AdminRefundedEvent")
      package_workspace = PackageWorkspace.any_in(package_order_id: package_orders_id).where(:"events._type" => "AdminRefundedEvent")
    end

    case params[:type]
    when "all"
      job_workspace + service_workspace + package_workspace + task_workspace
    when "job"
      job_workspace.created_at_desc
    when "service"
      service_workspace.created_at_desc
    when "package"
      package_workspace.created_at_desc
    when "task"
      task_workspace.created_at_desc
    end
  end

  # count orders completed by this member
  def orders_completed
    # TODO:
    # How about service ?
    result = Array.new
    self.jobs.unscoped.each do |j|
      j.orders.each do |o|
        if !o.workspace.blank?
          result << o if o.workspace.completed?
        end
      end
    end
    result
  end

  # method to populate email validation key for new account
  def generate_email_validation_key
    # Auto activated for employer
    # self.email_validation_key = SecureRandom.base64(8)
  end

  def push_to_cakemail
    # CakemailWorker.perform_async(perform: :new_subscriber, email: self.email, name: self.name, phone: self.country.phone_code + self.contact_number, contact_list: "reg_web_employer_#{self.locale.to_s}")
  end

  def push_to_infusionsoft
    InfusionsoftWorker.perform_async(employer_id: self.id.to_s, perform: :tag_employer)
  end

  # find last order for a given service
  def last_service_order(service)
    ServiceOrder.find_by(employer_id: self.id, service_id: service.id)
  end
  
  # get active jobs owned by this employer
  def active_jobs
    result = Array.new
    self.jobs.each do |j|
      if j.private?
        result << j
      elsif j.active?
        result << j
      end
    end
    result
  end

  def active_jobs_select_list
    result = Array.new
    
    self.active_jobs.each do |job|
      if job.private?
        result << ["Private - #{job.title}", job.id]
      else
        result << ["Public - #{job.title}", job.id]
      end
    end
    
    result
  end

  def update_employer_company_info(recruitment)
    self.update_attribute(:company_name, recruitment.company_name)
    self.update_attribute(:company_profile, recruitment.company_profile)
    self.update_attribute(:company_overview, recruitment.company_overview)
    self.update_attribute(:company_name_permanent, recruitment.company_name.parameterize) if self.company_name_permanent.strip=="" and recruitment.company_name.strip!=""
  end

  # check if employer profile completed
  def profile_completed?
    !self.name.blank? and !self.country.blank? and !self.contact_number.blank?
  end

  # check if employer has a job draft
  def has_job_draft?
    self.jobs.draft_only.count > 0
  end

  private

  def notify_km
    KissmetricsWorker.perform_async(perform: :employer_signup, identity: self.email, properties: {})
  end

end
