class Log

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'logs'
  belongs_to :member
  belongs_to :user
  field :type

 end
