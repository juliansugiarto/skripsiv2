class IndustryLancer

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'industries'
  field :slug
  field :name, type: Hash, default: {}
  field :name_seo, type: Hash, default: {}
  field :sid, type: Integer

  has_many :recruitments
  has_many :employer_member

  def dropdown_display
    self.name[I18n.locale]
  end
end
