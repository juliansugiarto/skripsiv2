# represent prefered language
class PreferedLanguage

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'prefered_languages'
  field :name

  has_and_belongs_to_many :members

  validates :name, :uniqueness => true
end
