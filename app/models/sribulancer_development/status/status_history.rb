class StatusHistory

  include Mongoid::Document
  include Mongoid::Timestamps

  field :status
  field :reason
  
  belongs_to :user, :foreign_key => :user_id, inverse_of: nil
  
  embedded_in :job
  embedded_in :service
end
