class RecapDailyList
  include Mongoid::Document
  include Mongoid::Timestamps

  TYPE = ['Job']

  field :type

  embedded_in :recap_daily
  
  belongs_to :job, inverse_of: nil
  belongs_to :recruitment, inverse_of: nil
  
end
