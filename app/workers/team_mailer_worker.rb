class TeamMailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    send(options['perform'], options) if respond_to? options['perform']
  end

  def send_new_employer(options)
    member = Member.find options['member_id']
    TeamMailer.send_new_employer(member).deliver
  end

  def send_new_freelancer(options)
    member = Member.find options['member_id']
    TeamMailer.send_new_freelancer(member).deliver
  end

  def send_new_task_application(options)
    task_application = TaskApplication.find options['task_application_id']
    TeamMailer.send_new_task_application(task_application).deliver
  end

  def send_new_job_order(options)
    job_order = JobOrder.find options['job_order_id']
    TeamMailer.send_new_job_order(job_order).deliver
  end

  def send_new_package_order(options)
    package_order = PackageOrder.find options['package_order_id']
    TeamMailer.send_new_package_order(package_order).deliver
  end

  def send_new_service_order(options)
    service_order = ServiceOrder.find options['service_order_id']
    TeamMailer.send_new_service_order(service_order).deliver
  end

  def send_job_order_paid(options)
    job_order = JobOrder.find options['job_order_id']
    TeamMailer.send_job_order_paid(job_order).deliver
  end

  def send_package_order_paid(options)
    package_order = PackageOrder.find options['package_order_id']
    TeamMailer.send_package_order_paid(package_order).deliver
  end

  def send_task_order_paid(options)
    task_order = TaskOrder.find options['task_order_id']
    TeamMailer.send_task_order_paid(task_order).deliver
  end

  def send_service_order_paid(options)
    service_order = ServiceOrder.find options['service_order_id']
    TeamMailer.send_service_order_paid(service_order).deliver
  end

  def send_status_event(options)
    workspace = Workspace.find options['workspace_id']
    status_event = workspace.events.find options['status_event_id']
    TeamMailer.send_status_event(workspace, status_event).deliver
  end

  def send_contact_us_form(options)
    email = options['email']
    contact_number = options['contact_number']
    description = options['description']
    TeamMailer.send_contact_us_form(email, contact_number, description).deliver
  end

  def send_notif_workspace_cancel(options)
    workspace = Workspace.find(options['workspace'])
    TeamMailer.send_notif_workspace_cancel(workspace).deliver
  end

  def send_request_help(options)
    sender = Member.find options['member_id']
    workspace = Workspace.find options['workspace_id']
    workspace_link = options['workspace_link']
    additional_information = options['additional_information']
    topic = options['topic']

    if workspace._type == 'JobWorkspace'
      workspace_title = workspace.job_order.job.title
      employer        = workspace.job_order.job.member
      freelancer      = workspace.job_order.job_application.member
    elsif workspace._type == 'PackageWorkspace'
      sender          = workspace.package_order.employer
      workspace_title = workspace.package_order.package.title
      employer        = workspace.package_order.employer
      freelancer      = workspace.package_order.freelancer
    else
      workspace_title = workspace.service_order.service.title
      employer        = workspace.service_order.employer
      freelancer      = workspace.service_order.freelancer
    end

    TeamMailer.send_request_help(sender, employer, freelancer, workspace_title, topic, additional_information, workspace_link).deliver
  end

  def send_new_private_job(options)
    job_offer = JobOffer.find options['job_offer_id']
    TeamMailer.send_new_private_job(job_offer).deliver
  end

  def send_error_veritrans_411(options)
    order = Order.find options['order_id']
    TeamMailer.send_error_veritrans_411(order).deliver
  end

  def send_test_email(options)
    subject = options['subject']
    message = options['message']
    TeamMailer.send_test_email(subject, message).deliver
  end

  def send_package_workspace_created(options)
    package_order = PackageOrder.find options['package_order_id']
    TeamMailer.send_package_workspace_created(package_order).deliver
  end

end
