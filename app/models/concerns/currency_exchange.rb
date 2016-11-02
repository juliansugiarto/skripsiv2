# Setup currency when object created by time
module CurrencyExchange

  def set_currency_exchanges
    if self.currency_exchanges.blank?
      self.currency_exchanges = SystemConfiguration.currency_exchanges
    end
  end

end
