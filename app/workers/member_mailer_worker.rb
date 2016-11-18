class MemberMailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    send(options['perform'], options) if respond_to? options['perform']
  end

  def send_registration_success_to_employer(options)
    member = Member.find options['member_id']
    MemberMailer.send_registration_success_to_employer(member).deliver
  end

  def send_registration_success_to_freelancer(options)
    member = Member.find options['member_id']
    MemberMailer.send_registration_success_to_freelancer(member).deliver
  end

  def send_registration_success_to_service_provider(options)
    member = Member.find options['member_id']
    MemberMailer.send_registration_success_to_service_provider(member).deliver
  end

  def send_reset_password(options)
    member = Member.find options['member_id']
    MemberMailer.send_reset_password(member).deliver
  end

  def send_new_job_application(options)
    member = Member.find options['member_id']
    job_application = JobApplication.find options['job_application_id']
    MemberMailer.send_new_job_application(member, job_application).deliver
  end 

  def send_new_task_application(options)
    member = Member.find options['member_id']
    task_application = TaskApplication.find options['task_application_id']
    MemberMailer.send_new_task_application(member, task_application).deliver
  end

  def send_invoice_to_employer(options)
    member = Member.find options['member_id']
    job_order = JobOrder.find options['job_order_id'] 
    if job_order.promotion.present?
      promotion = Promotion.find job_order.promotion 
      MemberMailer.send_invoice_to_employer(member, job_order, promotion).deliver
    else
      MemberMailer.send_invoice_to_employer(member, job_order).deliver
    end
  end

  def send_package_invoice_to_employer(options)
    member = Member.find options['member_id']
    package_order = PackageOrder.find options['package_order_id'] 
    if package_order.promotion.present?
      promotion = Promotion.find package_order.promotion 
      MemberMailer.send_package_invoice_to_employer(member, package_order, promotion).deliver
    else
      MemberMailer.send_package_invoice_to_employer(member, package_order).deliver
    end
  end

  def send_service_invoice_to_employer(options)
    member = Member.find options['member_id']
    service_order = ServiceOrder.find options['service_order_id']
    if service_order.promotion.present?
      promotion = Promotion.find service_order.promotion
      MemberMailer.send_service_invoice_to_employer(member, service_order, promotion).deliver
    else
      MemberMailer.send_service_invoice_to_employer(member, service_order).deliver  
    end

  end

  def send_job_paid_to_employer(options)
    member = Member.find options['member_id']
    job_order = JobOrder.find options['job_order_id']
    MemberMailer.send_job_paid_to_employer(member, job_order).deliver
  end

  def send_job_paid_to_freelancer(options)
    member = Member.find options['member_id']
    job_order = JobOrder.find options['job_order_id']
    MemberMailer.send_job_paid_to_freelancer(member, job_order).deliver
  end

  def send_package_paid_to_employer(options)
    member = Member.find options['member_id']
    package_order = PackageOrder.find options['package_order_id']
    MemberMailer.send_package_paid_to_employer(member, package_order).deliver
  end

 def send_task_paid_to_employer(options)
    member = Member.find options['member_id']
    task_order = TaskOrder.find options['task_order_id']
    MemberMailer.send_task_paid_to_employer(member, task_order).deliver
  end

  def send_task_paid_to_service_provider(options)
    member = Member.find options['member_id']
    task_order = TaskOrder.find options['task_order_id']
    MemberMailer.send_task_paid_to_service_provider(member, task_order).deliver
  end

  def resend_job_paid_to_employer(options)
    flag_send = true
    member = Member.find options['member_id']
    job_order = JobOrder.find options['job_order_id']

    job_order.workspace.events.each do |e|
      if e.member == member # Berarti si employer sudah aktif di workspace tersebut.
        flag_send = false
        break
      end
    end

    MemberMailer.send_job_paid_to_employer(member, job_order).deliver if flag_send == true
  end

  def resend_task_paid_to_employer(options)
    flag_send = true
    member = Member.find options['member_id']
    task_order = TaskOrder.find options['task_order_id']

    task_order.workspace.events.each do |e|
      if e.member == member # Berarti si employer sudah aktif di workspace tersebut.
        flag_send = false
        break
      end
    end

    MemberMailer.send_task_paid_to_employer(member, task_order).deliver if flag_send == true
  end

  def resend_job_paid_to_freelancer(options)
    flag_send = true
    member = Member.find options['member_id']
    job_order = JobOrder.find options['job_order_id']

    job_order.workspace.events.each do |e|
      if e.member == member # Berarti si freelancer sudah aktif di workspace tersebut.
        flag_send = false
        break
      end
    end

    MemberMailer.send_job_paid_to_freelancer(member, job_order).deliver if flag_send == true
  end

  def resend_task_paid_to_service_provider(options)
    flag_send = true
    member = Member.find options['member_id']
    task_order = TaskOrder.find options['task_order_id']

    task_order.workspace.events.each do |e|
      if e.member == member # Berarti si freelancer sudah aktif di workspace tersebut.
        flag_send = false
        break
      end
    end

    MemberMailer.send_task_paid_to_service_provider(member, task_order).deliver if flag_send == true
  end

  def send_service_paid_to_employer(options)
    member = Member.find options['member_id']
    service_order = ServiceOrder.find options['service_order_id']
    MemberMailer.send_service_paid_to_employer(member, service_order).deliver
  end

  def send_service_paid_to_freelancer(options)
    member = Member.find options['member_id']
    service_order = ServiceOrder.find options['service_order_id']
    MemberMailer.send_service_paid_to_freelancer(member, service_order).deliver
  end

  def send_message_event(options)
    member = Member.find options['member_id']
    workspace = Workspace.find options['workspace_id']
    message_event = workspace.events.find options['message_event_id']
    MemberMailer.send_message_event(member, workspace, message_event).deliver
  end

  def send_chat_message_event(options)
    member = Member.find options['member_id']
    chat = Chat.find options['chat_id']
    chat_message_event = chat.events.find options['chat_message_event_id']
    MemberMailer.send_chat_message_event(member, chat, chat_message_event).deliver
  end

  def send_status_event(options)
    member = Member.find options['member_id']
    workspace = Workspace.find options['workspace_id']
    status_event = workspace.events.find options['status_event_id']
    MemberMailer.send_status_event(member, workspace, status_event).deliver
  end

  def send_payout_released_event(options)
    member = Member.find options['member_id']
    workspace = Workspace.find options['workspace_id']
    status_event = workspace.events.find options['status_event_id']
    MemberMailer.send_payout_released_event(member, workspace, status_event).deliver
  end

  def send_admin_switched_freelancer_package_event_to_employer(options)
    member = Member.find options['member_id']
    workspace = Workspace.find options['workspace_id']
    event = workspace.events.find options['event_id']
    MemberMailer.send_admin_switched_freelancer_package_event_to_employer(member, event, workspace).deliver
  end

  def send_admin_switched_freelancer_package_event_to_freelancer(options)
    member = Member.find options['member_id']
    workspace = Workspace.find options['workspace_id']
    event = workspace.events.find options['event_id']
    MemberMailer.send_admin_switched_freelancer_package_event_to_freelancer(member, event, workspace).deliver
  end 

  def send_admin_switched_freelancer_package_event_to_prev_freelancer(options)
    member = Member.find options['member_id']
    workspace = Workspace.find options['workspace_id']
    event = workspace.events.find options['event_id']
    MemberMailer.send_admin_switched_freelancer_package_event_to_prev_freelancer(member, event, workspace).deliver
  end 

  def send_admin_refunded_event_to_employer(options)
    member = Member.find options['member_id']
    workspace = Workspace.find options['workspace_id']
    MemberMailer.send_admin_refunded_event_to_employer(member, workspace).deliver
  end


  def send_admin_refunded_event_to_freelancer(options)
    member = Member.find options['member_id']
    workspace = Workspace.find options['workspace_id']
    MemberMailer.send_admin_refunded_event_to_freelancer(member, workspace).deliver
  end

  def send_job_approval(options)
    job = Job.unscoped.find options['job_id']
    MemberMailer.send_job_approval(job).deliver if job.status == Status::APPROVED
  end

  def send_task_approval(options)
    task = Task.unscoped.find options['task_id']
    MemberMailer.send_task_approval(task).deliver if task.status == Status::APPROVED
  end 

  def send_task_wait_for_approval(options)
    task = Task.unscoped.find options['task_id']
    MemberMailer.send_task_wait_for_approval(task).deliver if task.status == Status::REQUESTED
  end

  def send_private_job_approval(options)
    job = Job.unscoped.find options['job_id']
    MemberMailer.send_private_job_approval(job).deliver
  end

  def send_job_rejection(options)
    job = Job.unscoped.find options['job_id']
    MemberMailer.send_job_rejection(job).deliver
  end

  def send_private_job_rejection(options)
    job = Job.unscoped.find options['job_id']
    MemberMailer.send_private_job_rejection(job).deliver
  end

  def send_service_approval(options)
    service = Service.unscoped.find options['service_id']
    MemberMailer.send_service_approval(service).deliver
  end

  def send_service_rejection(options)
    service = Service.unscoped.find options['service_id']
    MemberMailer.send_service_rejection(service).deliver
  end

  def send_new_job_to_freelancer(options)
    member = Member.find options['member_id']
    job = Job.unscoped.find options['job_id']
    MemberMailer.send_new_job_to_freelancer(member, job).deliver if job.status == Status::APPROVED
  end

  def send_freelancer_hired_to_other_applicants(options)
    member = Member.find options['member_id']
    job_order = JobOrder.find options['job_order_id']
    MemberMailer.send_freelancer_hired_to_other_applicants(member, job_order).deliver
  end

  def send_no_hiring_to_freelancer(options)
    member = Member.find options['member_id']
    job = Job.unscoped.find options['job_id']
    MemberMailer.send_no_hiring_to_freelancer(member, job).deliver
  end

  def send_eliminated_to_freelancer(options)
    job_application = JobApplication.find options['job_application_id']
    MemberMailer.send_eliminated_to_freelancer(job_application).deliver
  end

  def send_payout_method_validation(options)
    member = Member.find options['member_id']
    payout_method = member.payout_methods.active_only.find options['payout_method_id']
    MemberMailer.send_payout_method_validation(member, payout_method).deliver if payout_method.present?
  end

  def send_reminder_to_pay_job_order(options)
    member = Member.find options['member_id']
    job_order = JobOrder.find options['job_order_id']

    # do not send reminder if order already paid or rejected by Admin
    return if job_order.paid? or job_order.rejected?

    MemberMailer.send_reminder_to_pay_job_order(member, job_order).deliver
  end

  def send_reminder_to_pay_service_order(options)
    member = Member.find options['member_id']
    service_order = ServiceOrder.find options['service_order_id']

    # do not send reminder if order already paid or rejected by Admin
    return if service_order.paid? or service_order.rejected?

    MemberMailer.send_reminder_to_pay_service_order(member, service_order).deliver
  end

  def send_job_offer_to_freelancer(options)
    job_offer = JobOffer.find options['job_offer_id']
    MemberMailer.send_job_offer_to_freelancer(job_offer).deliver
  end

  def send_new_job_to_employer(options)
    job = Job.unscoped.find options['job_id']
    MemberMailer.send_new_job_to_employer(job).deliver
  end

  # Send unread notification via email everyday at 8.30 am
  def send_unread_notification_to_member(options)
    workspace_unread = options['workspace_unread']
    chat_unread = options['chat_unread']
    member = Member.find(options['member_id'])
    MemberMailer.send_unread_notification_to_member(member, workspace_unread, chat_unread).deliver
  end

  # Send semminder after no activity about 2 days
  def send_reminder_no_activity(options)
    mailer_content = options['mailer_content']
    MemberMailer.send_reminder_no_activity(mailer_content).deliver if mailer_content.present?
  end

  def send_apply_job_to_freelancer(options)
    freelancer = Member.find(options['freelancer_id'])
    job = Job.find(options['job_id'])
    MemberMailer.send_apply_job_to_freelancer(freelancer, job).deliver
  end

  def send_package_workspace_created_to_employer(options)
    member = Member.find options['member_id']
    package_order = PackageOrder.find options['package_order_id']
    MemberMailer.send_package_workspace_created_to_employer(member, package_order).deliver
  end

  def send_package_workspace_created_to_freelancer(options)
    member = Member.find options['member_id']
    package_order = PackageOrder.find options['package_order_id']
    MemberMailer.send_package_workspace_created_to_freelancer(member, package_order).deliver
  end

end
