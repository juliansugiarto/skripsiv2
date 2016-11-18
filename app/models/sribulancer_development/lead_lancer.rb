class LeadLancer
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'leads'
  scope :created_between, ->(start_period, end_period) { where(:created_at.gt => start_period, :created_at.lte => end_period) }

  field :name
  field :email
  field :country_id #add for input lead from frontend
  field :contact_number
  field :job_needed
  field :status
  field :budget

  # FLAG
  field :fu, type: Boolean, default: true

  # Validation
  validates :name, presence: true
  # validates :email, uniqueness: true


  # Relation
  has_one :follow_up
  belongs_to :country
  
end
