class HandymanPlumberContractorBrief < TaskBrief

  # every brief should have partial name
  PARTIAL_NAME = "handyman_plumber_contractor_1"

  field :type_of_work
  field :part_of_pipe
  field :size_of_pipe
  field :time_to_fix, type: DateTime

  def self.permitted_params
    [:id, :part_of_pipe, :size_of_pipe, :time_to_fix, :type_of_work => []]
  end
end
