class ReportBlastEmail
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'report_blast_emails'
  CONTEXT_BLAST_NEW_JOB = "blast new job to freelancers"
  CONTEXT_BLAST_NEW_RECRUITMENT = "blast new full time job to freelancers"
  CONTEXT_DAILY_NOTIFICATION_NEW_APPLICANT = "daily notification new applicant"
  CONTEXT_DAILY_NOTIFICATION_NEW_APPLICANT_FULL_TIME = "daily notification new applicant for full time job"

  belongs_to :job
  belongs_to :recruitment
  belongs_to :user

  field :context
  field :total_recipients

end
