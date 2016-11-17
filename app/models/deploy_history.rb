class DeployHistory
  include Mongoid::Document
  include Mongoid::Timestamps

  field :hostname
  field :gitlog
  field :note
end
