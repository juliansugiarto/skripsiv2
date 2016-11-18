# represent review given to member after a job
class ReviewLancer

  include Mongoid::Document
  include Mongoid::Timestamps

  DESCRIPTION_MINIMUM_LENGTH = 20
  DESCRIPTION_MAXIMUM_LENGTH = 300
	DESCRIPTION_MAXIMUM_LENGTH_DB = 320

  field :description
  field :rating, type: Integer

  belongs_to :reviewer, :class_name => "Member", :foreign_key => 'reviewer_id'
  belongs_to :workspace

  embedded_in :member
  
  validates :reviewer, presence: true
  validates :rating, presence: true, :numericality => {:only_integer => true, :maximum => 5, :minimum => 1}
  validates :description, presence: true, :length => { :minimum => DESCRIPTION_MINIMUM_LENGTH, :maximum => DESCRIPTION_MAXIMUM_LENGTH_DB }

end
