class Zenziva

  class << self

    USERKEY = ENV['ZENZIVA_USERKEY']
    PASSKEY = ENV['ZENZIVA_PASSKEY']
    
    def send_sms(to, text)
      if to.present? && to.strip!="" && text.present? && text.strip!=""
        server_url = "http://alpha.zenziva.net/apps/smsapi.php?" \
          + 'userkey=' + USERKEY \
          + '&passkey=' + PASSKEY \
          + '&nohp=+' + to \
          + '&pesan=' + text

        server_url = URI.escape (server_url)
        @result    = Hash.from_xml open(server_url, "UserAgent" => "Ruby-OpenURI").read
        # puts "SMS SENT TO " + to + " : " + text +  "\n===================="
      end
    end

    ### Check SMS Credit
    def check_credit
      server_url = "http://alpha.zenziva.net/apps/getbalance.php?" \
      + "userkey=" + USERKEY \
      + "&passkey=" + PASSKEY

      server_url = URI.escape (server_url)
      result     = JSON.parse(open(server_url, "UserAgent" => "Ruby-OpenURI").read)
      return result["Credit"]
    end

  end

end
