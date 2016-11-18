class Status

  # Job / Service
  REJECTED = 'rejected'
  REQUESTED = 'requested'
  APPROVED = 'approved'
  CLOSED = 'closed'
  DELETED = 'deleted'
  NO_HIRED = 'no_hired'
  HIRED = 'hired'
  DRAFT = 'draft'

  # Payout Method
  SUBMITTED = 'submitted'
  VALIDATED = 'validated'

  FAVOURITED = 'favourited'
  ELIMINATED = 'eliminated'

  # JobOrder / ServiceOrder
  # These haven't implemented yet.
  UNPAID = 'unpaid'
  PAID = 'paid'

  # Follow Up Note
  FU_1 = 'Telepon tidak diangkat'
  FU_2 = 'Email tidak dibalas'
  FU_3 = 'pending'
  FU_4 = 'cancel'
  FU_5 = 'done'
  FU_6 = 'medium'
  FU_7 = 'urgent'


  # Leads
  LEAD_NR = 'not_registered'
  LEAD_R = 'registered'

  FU_MEMBER_1 = FU_3
  FU_MEMBER_2 = FU_4
  FU_MEMBER_3 = 'Potensial'
  FU_MEMBER_4 = 'Belum ada kebutuhan'
  FU_MEMBER_5 = 'Tidak ada kebutuhan'
  FU_MEMBER_6 = 'Salah register'

  def self.getLocaleName(data)
    return I18n.t('static.' + data).titleize
  end
end
