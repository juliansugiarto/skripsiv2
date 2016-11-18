class ServiceWorkspace < WorkspaceLancer

  belongs_to :service_order

  def employer
    self.service_order.employer
  end

  def freelancer
    self.service_order.service.member
  end

  def service
    self.service_order.service
  end

  def initialise_status
    employer_initiated_service_event = EmployerInitiatedServiceEvent.new
    employer_initiated_service_event.member = self.employer

    self.events << employer_initiated_service_event
    self.save
  end

  def title
    self.service_order.service.title
  end

  def order
    self.service_order
  end

end
