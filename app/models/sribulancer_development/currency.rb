# represent currency
class Currency
  extend Unscoped
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'currencies'
  field :name
  field :code
  field :exchange_rate_to_idr, type: Float
  field :precision_to_use, type: Integer

  validates :name, presence: true
  validates :code, presence: true, :uniqueness => true
  validates :exchange_rate_to_idr, presence: true

  has_many :jobs
  has_many :services

  unscope :jobs

  def convert_to_idr(amount)
    if self == Currency.get_idr
      amount
    else
      amount * self.exchange_rate_to_idr
    end
  end

  def convert_to_currency(other_currency, amount)
    if other_currency.present? and other_currency.code == "IDR"
      amount * self.exchange_rate_to_idr
    else
      (amount * self.exchange_rate_to_idr) / other_currency.exchange_rate_to_idr
    end
  end

  def self.select_list
    result = Array.new
    Currency.all.each do |currency|
      result << [currency.code, currency.id]
    end
    result
  end

  def self.get_idr
    Currency.find_by(code: 'IDR')
  end

  def self.get_usd
    Currency.find_by(code: 'USD')
  end

end
