# represent employment history for freelancer
class PaypalPayout < PayoutMethod

  EMAIL_MAXIMUM_LENGTH = 100

  validates :paypal_email,
    :length => { :maximum => EMAIL_MAXIMUM_LENGTH },
    :format => { :with => /\A[^@][\w.-]+@[\w.-]+[.][a-z]{2,4}\z/i}

end
