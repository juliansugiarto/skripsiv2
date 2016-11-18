class ReportTopEmployer

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'report_top_employers'
  field :date, type: Date

  belongs_to :employer_member

  field :job_posted
  field :job_approved
  field :jo_created
  field :jo_paid
  field :total_jo_paid
  field :total_jo_margin
end
