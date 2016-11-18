class SurveyAnswer

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'survey_answers'
  field :value

  belongs_to :visitor
  belongs_to :answer

end
