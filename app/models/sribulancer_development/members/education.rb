# represent employment history for freelancer
class Education

  include Mongoid::Document
  include Mongoid::Timestamps

  INSTITUTION_NAME_MINIMUM_LENGTH = 5
  INSTITUTION_NAME_MAXIMUM_LENGTH = 100
  FIELD_OF_STUDY_MINIMUM_LENGTH = 5
  FIELD_OF_STUDY_MAXIMUM_LENGTH = 100

  field :institution_name
  field :field_of_study
  field :from_year, type: Integer
  field :to_year, type: Integer
  field :still_studies_here, type: Boolean
  field :description

  embedded_in :member

  # validates :institution_name, presence: true, :length => { :minimum => INSTITUTION_NAME_MINIMUM_LENGTH, :maximum => INSTITUTION_NAME_MAXIMUM_LENGTH }
  # validates :field_of_study, :length => { :minimum => FIELD_OF_STUDY_MINIMUM_LENGTH, :maximum => FIELD_OF_STUDY_MAXIMUM_LENGTH }
  # validates :from_year, presence: true, :numericality => {:only_integer => true}
  # validates :to_year, presence: true, :numericality => {:only_integer => true}, :unless => :still_studies_here?
  # validates :from_year, profile_year_range: true

end
