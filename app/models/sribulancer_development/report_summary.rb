class ReportSummary

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'report_summaries'
  field :date, type: Date
  field :registered_employer
  field :registered_freelancer
  field :qualified_freelancer

  field :job_posted
  field :job_approved

  field :jo_created
  field :jo_paid
  field :total_jo_paid
  field :total_jo_margin

  field :service_posted
  field :service_approved
  
  field :so_created
  field :so_paid
  field :total_so_paid
  field :total_so_margin

  field :revenue
  field :profit
end
