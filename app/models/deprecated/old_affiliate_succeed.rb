class OldAffiliateSucceed
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'affiliate_succeeds'

  belongs_to :affiliate
  belongs_to :member
  belongs_to :contest
  belongs_to :bank_account

  has_one :payment, class_name: "OldPayout"

  field :commission, :type => Integer, default: 0
  field :has_paid, :type => Boolean, default: false
  field :payment_request, :type => Boolean, default: false
  field :payment_request_date, :type => Time
  field :paid_date, :type => Time

end
