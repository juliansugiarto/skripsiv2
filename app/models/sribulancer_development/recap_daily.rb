class RecapDaily
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'recap_dailies'
  field :member_type
  
  belongs_to :member
  
  embeds_many :recap_daily_lists
end
