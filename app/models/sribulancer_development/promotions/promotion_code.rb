class PromotionCode

  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include FullErrorMessages
  
  field :code
  field :used_by 

  embedded_in :promotion
  
end
