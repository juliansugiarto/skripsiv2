class StoreRejectReason
  include Mongoid::Document
  include Mongoid::Timestamps

  field :type
  field :reason

  field :user_id
  embedded_in :store_item, inverse_of: :reject_reasons

end
