class TaskBrief
  include Mongoid::Document
  include Mongoid::Timestamps
  
  embedded_in :task
  
end
