class FollowUp
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'follow_ups'
  belongs_to :member
  belongs_to :lead
  
  embeds_many :follow_up_notes
end
