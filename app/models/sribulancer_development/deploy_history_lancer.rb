class DeployHistoryLancer
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'deploy_histories'
  field :hostname
  field :gitlog
  field :note
end
