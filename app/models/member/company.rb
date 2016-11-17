class Company

  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :phone_number, type: Integer
  field :city, type: String
  field :state, type: String
  field :postal_code, type: Integer
  field :employees_number, type: Integer
  field :description, type: String

  #                                                                  Attr Accessor
  # ==============================================================================

  #                                                                       Relation
  # ==============================================================================
  belongs_to :industry

  has_many :employees, class_name: "Member", inverse_of: :employee_of
  has_one :contact_person, class_name: "Member", inverse_of: :contact_person_of

  #                                                                     Validation
  # ==============================================================================


  #                                                                       Callback
  # ==============================================================================

  #                                                                   Class Method
  # ==============================================================================
  validates_presence_of :name
  validates_uniqueness_of :name

  #                                                                Instance Method
  # ==============================================================================

end
