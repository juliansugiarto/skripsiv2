class ReportTopOnlineCategory

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'report_top_online_categories'
  field :date, type: Date

  belongs_to :online_category

  field :job_posted
  field :job_approved
  field :jo_created
  field :jo_paid
  field :jo_created_uniq
  field :jo_paid_uniq
  field :total_jo_paid
  field :total_jo_margin
end
