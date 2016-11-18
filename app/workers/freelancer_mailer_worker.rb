class FreelancerMailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    send(options['perform'], options) if respond_to? options['perform']
  end

  # Send daily recap new job to freelancer
  def send_recap_new_job_with_quota(options)
    mailer_content = options['mailer_content']
    FreelancerMailer.send_recap_new_job_with_quota(mailer_content).deliver if mailer_content.present?
  end

  # Send daily recap new job to freelancer
  def send_notification_closed_workspace(options)
    freelancer = FreelancerMember.find options['freelancer_id']
    employer = EmployerMember.find options['employer_id']
    workspace = Workspace.find options['workspace_id']
    FreelancerMailer.send_notification_closed_workspace(freelancer, employer, workspace).deliver
  end

  def blast_20160701_payout_notif(options)
    freelancers = FreelancerMember.qualified_only.where(:last_login.gte => Time.now-6.months)
    freelancers.each do |freelancer|
      MemberMailer.blast_20160701_payout_notif(freelancer).deliver
    end
  end

end
