# represent a country
class CountryLancer

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'countries'
  PRIORITY = ['id', 'sg', 'au']
  LIST_SEPARATOR = '---------------------'

  field :name
  field :code
  field :phone_code
  field :slug

  validates :name, presence: true
  validates :code, presence: true, :uniqueness => true
  validates :phone_code, presence: true

  before_save :set_slug

  def self.select_list_code
    result = Array.new

    # put priority country
    PRIORITY.each do |code|
      if country = Country.find_by(code: code)
        result << ["#{country.name} - +#{country.phone_code}", country.id]
      end
    end

    result << [LIST_SEPARATOR, LIST_SEPARATOR]

    Country.nin(code: PRIORITY).each do |country|
      result << ["#{country.name} - +#{country.phone_code}", country.id]
    end
    result
  end

  def indonesia?
    self.phone_code == "62" ? true : false
  end

  private

  def set_slug
    self.slug = self.name.to_s.parameterize
  end

end
