class Answer

  include Mongoid::Document
  include Mongoid::Timestamps

  TEXT = 'text'
  COUNT = 'count'

  field :no, type: Integer
  field :answer
  field :type

  embedded_in :question

  has_many :survey_answers

end
