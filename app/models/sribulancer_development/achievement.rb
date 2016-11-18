class Achievement
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'achievements'
  field :job_posted, type: Integer, default: 0
  field :total_job_orders_budget_in_idr, type: Float, default: 0
  field :total_freelancers, type: Integer, default: 0

  class << self
    private
  end

end
