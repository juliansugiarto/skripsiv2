class Role

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'roles'
  field :name

  embeds_many :role_rules
  
end
