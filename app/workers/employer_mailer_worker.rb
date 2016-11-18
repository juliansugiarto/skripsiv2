class EmployerMailerWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    send(options['perform'], options) if respond_to? options['perform']
  end

  def send_daily_application_list(options)
    job = Job.find options['job_id']

    # in case cron started in the next minutes, 08.03
    # with this code, you can move this cron anywhere in schedule.rb
    to = DateTime.now.at_beginning_of_hour
    from = to - 1.day

    ja = job.job_applications.includes(:member).where(created_at: from..to).limit(3)


    if job.member.email_notif_daily_recap_job_freelance.present? and job.member.email_notif_daily_recap_job_freelance == true
      if ja.any? and job.member.email_validated?
        EmployerMailer.send_daily_application_list(job, ja, from, to).deliver
        ReportBlastEmail.new(:job => job, :total_recipients => 1, :context => ReportBlastEmail::CONTEXT_DAILY_NOTIFICATION_NEW_APPLICANT).save
      end
    end
  end

  def send_notify_employer_to_check_applicants(options)
    member = Member.find options['member_id']
    job = Job.unscoped.find options['job_id']
    EmployerMailer.send_notify_employer_to_check_applicants(member, job).deliver
  end

  # Send remind about our product to employer who register after 7 day but never create job/service.
  def send_reminder_about_us(options)
    member = Member.find options['member_id']
    EmployerMailer.send_reminder_about_us(member).deliver
  end

  def send_thank_you_closed_workspace(options)
    freelancer = FreelancerMember.find options['freelancer_id']
    employer = EmployerMember.find options['employer_id']
    workspace = Workspace.find options['workspace_id']
    EmployerMailer.send_thank_you_closed_workspace(freelancer, employer, workspace).deliver
  end

end
