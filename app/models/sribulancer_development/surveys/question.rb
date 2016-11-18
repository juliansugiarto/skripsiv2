class Question

  include Mongoid::Document
  include Mongoid::Timestamps

  field :no, type: Integer
  field :question

  embedded_in :survey
  embeds_many :answers

end
