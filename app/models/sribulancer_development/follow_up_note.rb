class FollowUpNote
  include Mongoid::Document
  include Mongoid::Timestamps
  field :text
  field :status
  # Possible value for this field 
  # To identify what kind of follow up this row belongs to.

  TYPE = ['Member', 'Job', 'JobOrder', 'Service', 'ServiceOrder', 'Task', 'TaskOrder', 'Lead', 'ServiceProviderLead', 'PackageOrder']
  STATUS = [StatusLancer::FU_1, StatusLancer::FU_2, StatusLancer::FU_3, StatusLancer::FU_4, StatusLancer::FU_5]
  STATUS_DIANA = [StatusLancer::FU_6, StatusLancer::FU_7]
  STATUS_MEMBER = [StatusLancer::FU_MEMBER_1, StatusLancer::FU_MEMBER_2, StatusLancer::FU_MEMBER_3, StatusLancer::FU_MEMBER_4, StatusLancer::FU_MEMBER_5, StatusLancer::FU_MEMBER_6]

  field :type
  field :reminder_time, :type => DateTime

  # This field is User.username
  # Prevent error when user deleted, so save username instead.
  field :username

  embedded_in :follow_up
  
  belongs_to :job, inverse_of: nil
  belongs_to :task, inverse_of: nil
  belongs_to :service, inverse_of: nil
  belongs_to :job_order, inverse_of: nil
  belongs_to :task_order, inverse_of: nil
  belongs_to :service_order, inverse_of: nil
  belongs_to :package_order, inverse_of: nil
  belongs_to :recruitment, inverse_of: nil
  belongs_to :member
  belongs_to :lead
  belongs_to :service_provider_lead
  belongs_to :workspace

  after_create :update_fu

  def update_fu
    # If type lead, do nothing
    if self.type == "Lead" || self.type == "ServiceProviderLead"

    else
      t = self.type.classify
      if self.type == "Member"
        # Karena followup note ngga simpan member_id, melainkan ada di root documentnya
        obj = MemberLancer.find self.follow_up.member
      else
        obj = t.constantize.find self.send("#{t.underscore.downcase}_id")
      end
      obj.update_attribute(:fu, true)
    end
  end
end
