class WorkspaceHelp
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'workspace_helps'
  field :topic
  field :additional_information
  field :member_type

  belongs_to :workspace
  belongs_to :member
end
