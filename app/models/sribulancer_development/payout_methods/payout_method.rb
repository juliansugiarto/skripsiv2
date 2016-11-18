# represent employment history for freelancer
class PayoutMethod

  include Mongoid::Document
  include Mongoid::Timestamps

  field :paypal_email

  field :bank_name
  field :account_number
  field :account_name
  field :branch

  field :default, type: Boolean
  field :status
  field :validation_key
  
  embedded_in :member

  scope :active_only, ->{ any_in(status: [StatusLancer::SUBMITTED, StatusLancer::VALIDATED]) }
  scope :validated_only, ->{ any_in(status: [StatusLancer::VALIDATED]) }

  before_create :set_initial_state, :generate_validation_key

  after_create :send_validation_email

  # when created, job must be not be approved
  def set_initial_state
    General::ChangeStatusService.new(self, StatusLancer::SUBMITTED).change_status_only
  end

  # method to populate salt for new account
  def generate_validation_key
    self.validation_key = SecureRandom.base64(8)
  end

  # every new payout need to be approved via email
  def send_validation_email
    MemberMailerWorker.perform_async(payout_method_id: self.id.to_s, member_id: self.member.id.to_s, perform: :send_payout_method_validation)
  end

  # validate this payout method, can be used now
  def validate
    # if this is the first one, set to default right away
    self.default = true if self.member.payout_methods.validated_only.count == 0
    General::ChangeStatusService.new(self, StatusLancer::VALIDATED).change_status_only
    self.save
  end

  def validated?
    self.status == StatusLancer::VALIDATED
  end

  def paypal_payout?
    self.class == PaypalPayout
  end

  def bank_transfer_payout?
    self.class == BankTransferPayout
  end

  # set as default, and take out default from the others payout method
  # only one allowed to be default
  def set_default
    self.member.payout_methods.active_only.each do |pm|
      pm.update_attribute(:default, false) if pm.default?
    end
    self.update_attribute(:default, true)
  end

  def delete
    General::ChangeStatusService.new(self, StatusLancer::DELETED).change_status_only
    self.save
  end

end
