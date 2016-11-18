class Shortlist

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'shortlists'
  belongs_to :employer, :class_name => "EmployerMember", :foreign_key => :employer_id
  belongs_to :freelancer, :class_name => "FreelancerMember", :foreign_key => :freelancer_id

  validates :freelancer_id, presence: true
  validates :employer_id, presence: true
  validates :freelancer_id, uniqueness: { scope: :employer_id }

  scope :created_at_desc, -> {desc(:created_at)}

  def self.exist?(employer, freelancer)
    Shortlist.where(employer: employer, freelancer: freelancer).present?
  end

end
