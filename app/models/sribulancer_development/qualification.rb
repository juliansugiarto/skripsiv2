class Qualification

  # Used for recruitment

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'qualifications'
  field :name, type: Hash, default: {}
  field :sort, type: Integer

  has_many :recruitments


  def dropdown_display
    self.name[I18n.locale]
  end

end
