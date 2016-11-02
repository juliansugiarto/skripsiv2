class OldExtraField
  include Mongoid::Document
  include Mongoid::Timestamps

  store_in collection: 'extra_fields'

  belongs_to :extra_field_type, class_name: "OldExtraFieldType"
  belongs_to :category
  has_many :extra_field_values, class_name: "OldExtraFieldValue"

  field :name
  field :description
  field :help
  field :active, :type => Boolean, :default => false
  field :optional, :type => Boolean, :default => true
  field :rank, :type => Integer, :default => 0
  field :name_en
  field :description_en

  validates_presence_of :name
  validates_numericality_of :rank
end
