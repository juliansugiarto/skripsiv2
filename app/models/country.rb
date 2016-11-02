class Country

  include Mongoid::Document
  include Mongoid::Timestamps

  #                                                                          Field
  # ==============================================================================
  field :name, type: String
  field :code, type: String
  field :phone_code, type: String


  #                                                                  Attr Accessor
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  has_many :members

  #                                                                     Validation
  # ==============================================================================
  validates :name, presence: true
  validates :code, presence: true, uniqueness: true
  validates :phone_code, presence: true


  #                                                                       Callback
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================


  #                                                                Instance Method
  # ==============================================================================
  def from_indonesia?
    self.phone_code == "62" ? true : false
  end

end
