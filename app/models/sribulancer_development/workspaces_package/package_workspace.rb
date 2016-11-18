class PackageWorkspace < Workspace

  belongs_to :package_order

  def package
    self.package_order.package if self.package_order.present?
  end

  def employer
    self.package_order.employer
  end

  def freelancer
    self.package_order.freelancer
  end
  
  def prev_freelancer
    self.package_order.prev_freelancer
  end

  def order
    self.package_order
  end

  def title
    self.package_order.package.title
  end

  def initialise_status
    employer_initiated_package_event = EmployerInitiatedPackageEvent.new
    employer_initiated_package_event.member = self.employer

    self.events << employer_initiated_package_event
    self.save
  end

  def switch_freelancer(new_freelancer, prev_freelancer=nil)
    package_order = self.package_order
    package_order.freelancer = new_freelancer
    package_order.prev_freelancer = prev_freelancer
    package_order.save(validate: false)

    self.freelancer_username = new_freelancer.username
    self.save
  end

end
