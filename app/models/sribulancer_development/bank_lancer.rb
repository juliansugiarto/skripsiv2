class BankLancer

  # Used for freelancer payout

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'banks'
  field :name

end
