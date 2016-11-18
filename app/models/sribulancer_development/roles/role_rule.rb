class RoleRule

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :actions, type: Array, default: []

  embedded_in :role

end
