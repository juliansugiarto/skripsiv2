class CleaningServiceBrief < TaskBrief
  
  # every brief should have partial name
  PARTIAL_NAME = "cleaning_service_1"

  field :type_of_work
  field :size_of_fix
  field :time_to_fix, type: DateTime
  field :tools_to_use
  field :optional_message

  def self.permitted_params
    [:id, :size_of_fix, :time_to_fix, :optional_message, :type_of_work => [], :tools_to_use => []]
  end
end
