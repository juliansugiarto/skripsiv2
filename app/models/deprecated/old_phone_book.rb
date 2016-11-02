class OldPhoneBook
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'phone_books'

  belongs_to :member
  field :mobile_phone_number
  field :phone_number
  field :migrated, default: false

end
