class ServiceProviderMailerWorker 
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    send(options['perform'], options) if respond_to? options['perform']
  end

  def send_recap_email_new_task_to_service_provider(options)
    task = Task.find(options['task_id'])
    service_providers = ServiceProviderMember.where(email_validation_key: nil, email_notif_new_task: true, disabled: false, company_category_id: options['company_category'])
    service_providers.each do |sp|
      ServiceProviderMailer.send_recap_email_new_task_to_service_provider(sp, task).deliver
    end
  end

  def send_email_to_wait_verification(options)
    sp = ServiceProviderMember.find(options['service_provider_id'])
    ServiceProviderMailer.send_email_to_wait_verification(sp).deliver
  end

  def send_notification_closed_workspace(options)
    service_provider = ServiceProviderMember.find options['service_provider_id']
    employer = EmployerMember.find options['employer_id']
    workspace = Workspace.find options['workspace_id']
    ServiceProviderMailer.send_notification_closed_workspace(service_provider, employer, workspace).deliver
  end

end