class Location

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'locations'
  field :name
  has_and_belongs_to_many :members
end
