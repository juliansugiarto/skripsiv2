# represent member for freelancer
class FreelancerMember < MemberLancer
  extend Unscoped
  include FullErrorMessages

  include Elasticsearch::Model
  include Elasticsearch::Model::Serializing
  # include Elasticsearch::Model::Callbacks

  MAXIMUM_EMPLOYMENTS = 5
  MAXIMUM_EDUCATIONS = 5
  CNAME = 'freelancer'

  # legacy not used anymore
  field :skills_legacy, type: Array, default: []

  # Optional Notification @edit_profile
  field :email_notif_new_job, type: Boolean, default: true

  field :verified, type: Boolean, default: false
  field :status

  # Mark as qualified by admin from backoffice
  field :qualified, type: Boolean, default: false

  # Title
  field :title

  field :partnership, type: Boolean, default: false
  field :partnership_start, type: DateTime
  field :partnership_end, type: DateTime

  embeds_many :employments
  embeds_many :educations
  embeds_many :reviews
  has_many :member_skill

  has_many :job_applications, :foreign_key => :member_id
  has_many :services, :foreign_key => :member_id
  has_many :job_offers, :foreign_key => :member_id
  has_many :member_preferences, :foreign_key => :member_id

  has_many :portfolios, :foreign_key => :member_id

  unscope :services

  validates_associated :employments
  validates_associated :educations

  accepts_nested_attributes_for :employments, allow_destroy: true, :reject_if => lambda { |a| a[:job_title].blank? }
  accepts_nested_attributes_for :educations, allow_destroy: true, :reject_if => lambda { |a| a[:institution_name].blank? }

  after_create {
    # Indexer::FreelancerMember.perform_async(:index, self.id.to_s)
    # MemberMailerWorker.perform_async(member_id: self.id.to_s, perform: :send_registration_success_to_freelancer)
  }

  after_update {
    # Index only if they qualified
    if self.last_activity.present? and self.last_activity_was.present? and ((Time.now.to_datetime - self.last_activity_was.localtime.to_datetime)*24*60).to_i >= 5 # 5 minutes difference
      if self.email_validation_key == nil and self.photo.present? and self.skill_ids != []
        Indexer::JobApplication.perform_async(:save, self.id.to_s)
        Indexer::FreelancerMember.perform_async(:index, self.id.to_s)
      end
    end
  }

  after_destroy {
    Indexer::FreelancerMember.perform_async(:destroy, self.id.to_s)
  }

  scope :created_between, ->(start_period, end_period) { where(:created_at.gt => start_period, :created_at.lte => end_period) }
  scope :qualified_only, -> { where(:email_validation_key => nil, :photo.ne => nil, :skill_ids.ne => nil) }

  def skill_with_ratings
    member_skills = MemberSkill.where(freelancer_member: self)

    skills = Array.new
    member_skills.each do |ms|
      skill = ms.skill
      skill_name = skill.name
      find_skill = skills.find { |k, v| k[:name] == skill_name }
      if find_skill.present?
        find_skill[:rating] = (find_skill[:rating] + ms.freelancer_review.rating)/2
        find_skill[:count] = find_skill[:count] + 1
      else
        skill[:rating] = ms.freelancer_review.rating
        skill[:count] = 1
        skills << skill
      end
    end

    # join skills from profile
    self.skills.each do |s|
      if !skills.find { |k, v| k[:name] == s.name }.present?
        s[:rating] = 0
        s[:count] = 0
        skills << s
      end
    end
    skills =  skills.sort_by { |h| [-h[:count], -h[:rating]]}
  end

  def reviews_avg
    number_with_precision(self.member_reviews.avg(:rating), precision: 1)
  end

  def reviews_count
    self.member_reviews.count
  end

  def rating
    self.member_reviews.avg(:rating)
  end

  def member_reviews
    return FreelancerReview.any_of({:id.in => MemberSkill.where(freelancer_member_id: self.id).distinct(:freelancer_review)})
  end

  def skills_legacy_list=(arg)
    self.skills_legacy = arg.split(',').map { |v| v.strip }
  end

  def skills_legacy_list
    self.skills_legacy.join(', ')
  end

  # method to check if freelancer profile is completed before applying for a job
  # does not apply if the user is testing user
  def profile_completed?
    return true if self.for_testing?
    !self.skills.blank? and !self.bio.blank?
  end

  # TODO:
  # We have 2 kind of workspaces now.
  # Service and Job
  # We need to separate this function.
  # Or maybe we can append service workspaces to this function.
  def workspaces(params)
    params[:status] = 'all' if params[:status].blank?

    job_applications_id = self.job_applications.collect &:id
    job_orders_id = JobOrder.any_in(job_application_id: job_applications_id).collect &:id

    services_id = self.services.collect &:id
    service_orders_id = ServiceOrder.any_in(service_id: services_id).collect &:id

    package_orders_id = PackageOrder.where(freelancer: self).collect &:id

    case params[:status]
    when "all"
      job_workspace = JobWorkspace.any_in(job_order_id: job_orders_id)
      service_workspace = ServiceWorkspace.any_in(service_order_id: service_orders_id)
      package_workspace = PackageWorkspace.any_in(package_order_id: package_orders_id)
    when "on_progress"
      job_workspace = JobWorkspace.any_in(job_order_id: job_orders_id).where( :"events._type" => {"$nin" => ["AdminCanceledEvent", "AdminRefundedEvent", "EmployerClosedJobEvent", "AdminReleasedPayoutEvent", "FreelancerRequestedPayoutEvent"]} )
      service_workspace = ServiceWorkspace.any_in(service_order_id: service_orders_id).any_in(service_order_id: service_orders_id).where( :"events._type" => {"$nin" => ["AdminCanceledEvent", "AdminRefundedEvent", "EmployerClosedJobEvent", "AdminReleasedPayoutEvent", "FreelancerRequestedPayoutEvent"]})
      package_workspace = PackageWorkspace.any_in(package_order_id: package_orders_id).where( :"events._type" => {"$nin" => ["AdminCanceledEvent", "AdminRefundedEvent", "EmployerClosedJobEvent", "AdminReleasedPayoutEvent", "FreelancerRequestedPayoutEvent"]})
     when "completed"
      job_workspace = JobWorkspace.any_in(job_order_id: job_orders_id).where( :"events._type" => { "$in" => ["EmployerClosedJobEvent", "AdminReleasedPayoutEvent"] } )
      service_workspace = ServiceWorkspace.any_in(service_order_id: service_orders_id).where( :"events._type" => { "$in" => ["EmployerClosedJobEvent", "AdminReleasedPayoutEvent"] } )
      package_workspace = PackageWorkspace.any_in(package_order_id: package_orders_id).where( :"events._type" => { "$in" => ["EmployerClosedPackageEvent", "AdminReleasedPayoutEvent"] } )

    when "cancelled"
      job_workspace = JobWorkspace.any_in(job_order_id: job_orders_id).where(:"events._type" => "AdminCanceledEvent")
      service_workspace = ServiceWorkspace.any_in(service_order_id: service_orders_id).where(:"events._type" => "AdminCanceledEvent")
      package_workspace = PackageWorkspace.any_in(package_order_id: package_orders_id).where(:"events._type" => "AdminCanceledEvent")

    when "refunded"
      job_workspace = JobWorkspace.any_in(job_order_id: job_orders_id).where(:"events._type" => "AdminRefundedEvent")
      service_workspace = ServiceWorkspace.any_in(service_order_id: service_orders_id).where(:"events._type" => "AdminRefundedEvent")
      package_workspace = PackageWorkspace.any_in(package_order_id: package_orders_id).where(:"events._type" => "AdminRefundedEvent")
    end

    if params[:username].present?
      job_workspace = job_workspace.where(employer_username: /#{Regexp.escape(params[:username])}/i)
      service_workspace = service_workspace.where(employer_username: /#{Regexp.escape(params[:username])}/i)
      package_workspace = package_workspace.where(employer_username: /#{Regexp.escape(params[:username])}/i)
    end

    job_workspace + service_workspace + package_workspace
  end


  # Return true if freelancer is qualified
  def is_qualified?
    if self.photo.present? and self.skill_ids.count > 0
      return true
    else
      return false
    end
  end

  # count job orders completed by this member
  def orders_completed
    result = Array.new
    self.job_applications.each do |j|
      j.orders.each do |order|
        if !order.blank? and !order.workspace.blank?
          result << order if order.workspace.completed?
        end
      end
    end
    result
  end

  # count job orders not completed by this member
  def orders_canceled_by_admin
    result = Array.new
    self.job_applications.each do |j|
      j.orders.each do |order|
        if !order.blank? and !order.workspace.blank?
          result << order if order.workspace.canceled_by_admin?
        end
      end
    end
    result
  end



  # count service orders completed by this member
  def service_orders_completed
    result = Array.new
    self.services.each do |s|
      s.orders.each do |order|
        if !order.blank? and !order.workspace.blank?
          result << order if order.workspace.completed?
        end
      end
    end
    result
  end

  # helper to find last order of this freelancer to a job
  def last_order(obj)
    if obj.class == Job
      job_application = JobApplication.find_by(member: self, job: obj)
      return nil if job_application.blank? or job_application.orders.blank?
      job_application.orders.created_at_desc.first
    elsif obj.class == Service
      return nil if obj.orders.blank?
      obj.orders.created_at_desc.first
    else
      return nil
    end
  end

  # helper to find member last hired for a job
  def last_hired(obj)

    if obj.class == Job
      last_order = last_order(obj)

      if last_order
        return last_order.created_at
      else
        return nil
      end
    elsif obj.class == Service
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

  def push_to_cakemail
    # CakemailWorker.perform_async(perform: :new_subscriber, email: self.email, name: self.name, phone: self.country.phone_code + self.contact_number, contact_list: "reg_web_freelancer_#{self.locale.to_s}")
  end

  # used for seo in show freelancer
  def get_first_n_skills(n)
    return '' if self.skill_ids.blank?
    self.skills.take(n).collect(&:name).join(', ')
    # @skills = Rails.cache.fetch("skills-#{self.id}-#{n}", expires_in: 1.hours) do
    #   self.skills.take(n).collect(&:name).join(', ')
    # end
    # return @skills
  end

  def get_job_freelance_from_matched(i)
    j_arr = []
    job_freelancers = Job.opened_only
    self.skills.each do |s|
      job_freelancers.each do |j|
        j_arr << j if j.skills.include? s
      end
    end
    return j_arr.sort_by { |i| i.due_date}.take(i)
  end

  # get skill categories
  def skill_categories
    group_category_ids = Array.new
    self.skill_with_ratings.each do |s|
      group_category_ids << s.online_group_category.id
    end
    group_category_ids.uniq
  end

  def send_thank_you_registering_email
    FreelancerMailer.send_thank_you_registering_email(self).deliver
  end

  def has_service_draft?
    self.services.draft_only.count > 0
  end

  def as_indexed_json(options={})
    self.as_json(
      except: [:id, :_id],
      methods: [:reviews_count, :reviews_avg, :member_reviews, :bf_sort_point],
      include: {
        prefered_languages: {
          only: [:name]
        },
        country: {
          only: [:name]
        },
        skills: {
          only: [:id, :name]
        },
        member_preferences: {
          only: [:online_category_id]
        }
      }
    )
  end

  # points based on reviews, last login
  # used to provide more dynamic in browse freelancer page
  def bf_sort_point
    point = 0

    # recent review worth more points
    self.member_reviews.each do |r|
      point += 10 if r.created_at > 2.weeks.ago
      point += 3 if r.created_at > 6.weeks.ago and r.created_at <= 2.weeks.ago
      point += 1 if r.created_at <= 6.weeks.ago 
    end

    point
  end

  # list all partnership freelancer
  def self.partnership_list(excluding_id = '')
    FreelancerMember.where(partnership: true, :id.ne => excluding_id)
  end

  private

  def notify_km
    KissmetricsWorker.perform_async(perform: :freelancer_signup, identity: self.email, properties: {})
  end


end
