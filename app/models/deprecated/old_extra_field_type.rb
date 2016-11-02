class OldExtraFieldType
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'extra_field_types'

  has_many :extra_fields, class_name: "OldExtraField"

  # type should be text, memo, html, file
  field :type
  field :name

  validates_presence_of :type
end
