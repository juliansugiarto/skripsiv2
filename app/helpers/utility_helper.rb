module UtilityHelper

  # By default, always return IDR value
  def sribu_currency(number, arg = {})
    # Get this currency from member/session
    currency = arg[:currency].present? ? arg[:currency].to_s : session[:currency].to_s

    if arg[:custom].present?
      rates = arg[:custom]
    else
      # Get configuration from api server
      rates = SystemConfiguration.currency_exchanges
    end

    exchange = {}
    # Display both currency
    rates.each do |r|
      if r[:code] == currency
        exchange = r[:value].to_f * number.to_f
      end
    end

    case currency
    when "idr"
      number_to_currency(exchange.to_f, precision: 0, unit: currency.upcase, separator: ",", delimiter: ".", format: "%u %n")
    when "usd"
      number_to_currency(exchange.to_f, precision: 2, unit: currency.upcase, separator: ".", delimiter: ",", format: "%u %n")
    end
  end

  def sribu_date(date)
    return "Date undefined" if date.blank?
    if date.is_a? String
      Time.parse(date).strftime("%d %B %Y at %I:%M%p")
    else
      date.strftime("%d %B %Y at %I:%M%p")
    end
  end


  # return date difference of a given date to today's date
  def date_age_in_words(date)
    (distance_of_time_in_words DateTime.current, date)
  end

  # return date difference of a given date to today's date
  def date_duration_in_words(date)
    if date > DateTime.now
      t('datetime.distance_in_words.in') + ' ' + (distance_of_time_in_words DateTime.current, date)
    else
      t('datetime.distance_in_words.ago')
    end
  end


  def is_remote_file_image?(url)

    url = URI.parse(url)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = (url.scheme == "https")

    http.start do |http|
      return http.head(url.request_uri)['Content-Type'].start_with? 'image'
    end
  rescue
    false
  end

  def is_eligible_using_vt?
    if controller_name == "payments" and controller.action_name == "select_payment"
      return true
    else
      return false
    end
  end

  def show_s3_path
    "https://sribu-sg.s3.amazonaws.com"
  end

end
