class BackofficeWorker

  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    # if want to test on development please uncomment below
    # please turn off before commit, so we do not waste our event quota in kissmetrics
    # return unless (Rails.env.staging? || Rails.env.production?)
    send(options['perform'], options) if respond_to? options['perform']
  end

  # Create recap daily new job for freelancer
  def recap_daily_for_new_job(options)
    job = Job.find options['job_id']
    admin_user = User.find options['admin_user_id']
    skills = job.skills.map(&:id)

    freelancers = FreelancerMember.where(email_validation_key: nil, email_notif_new_job: true, disabled: false)
    freelancers = freelancers.any_in(skill_ids: skills)

    freelancers.each do |fm|
      if fm.recap_daily.blank?
        fm.recap_daily = RecapDaily.create(member_type: fm._type)
      end
      fm.recap_daily.recap_daily_lists.create(type: 'Job', job_id: job.id)
    end

    job.update_attribute(:blast_email_to_freelancer, true)
    ReportBlastEmail.new(
      :job => job,
      :user => admin_user,
      :total_recipients => freelancers.size,
      :context => ReportBlastEmail::CONTEXT_BLAST_NEW_JOB).save
  end


end