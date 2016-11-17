# represent review given to member after a job
class Review

  include Mongoid::Document
  include Mongoid::Timestamps

  field :description
  field :rating, type: Integer

  belongs_to :reviewer, polymorphic: true
  belongs_to :workspace

  embedded_in :member

  validates :reviewer, presence: true
  validates :rating, presence: true, :numericality => {:only_integer => true, :maximum => 5, :minimum => 1}
  validates :description, presence: true

end
