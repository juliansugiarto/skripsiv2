class Survey

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'surveys'
  field :name

  embeds_many :questions

end
