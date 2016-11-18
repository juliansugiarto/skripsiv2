# represent employment history for freelancer
class Employment

  include Mongoid::Document
  include Mongoid::Timestamps

  JOB_TITLE_MINIMUM_LENGTH = 5
  JOB_TITLE_MAXIMUM_LENGTH = 100
  COMPANY_NAME_MINIMUM_LENGTH = 5
  COMPANY_NAME_MAXIMUM_LENGTH = 100
  DESCRIPTION_MINIMUM_LENGTH = 20
  DESCRIPTION_MAXIMUM_LENGTH = 1000
	DESCRIPTION_MAXIMUM_LENGTH_DB = 1200

  field :job_title
  field :company_name
  field :from_year, type: Integer
  field :to_year, type: Integer
  field :still_works_here, type: Boolean
  field :description

  embedded_in :member

  # validates :job_title, presence: true, :length => { :minimum => JOB_TITLE_MINIMUM_LENGTH, :maximum => JOB_TITLE_MAXIMUM_LENGTH }
  # validates :company_name, presence: true, :length => { :minimum => COMPANY_NAME_MINIMUM_LENGTH, :maximum => COMPANY_NAME_MAXIMUM_LENGTH }
  # validates :from_year, presence: true, :numericality => {:only_integer => true}
  # validates :to_year, presence: true, :numericality => {:only_integer => true}, :unless => :still_works_here?
  # validates :description, presence: true, :length => { :minimum => DESCRIPTION_MINIMUM_LENGTH, :maximum => DESCRIPTION_MAXIMUM_LENGTH_DB }
  # validates :from_year, profile_year_range: true

end
