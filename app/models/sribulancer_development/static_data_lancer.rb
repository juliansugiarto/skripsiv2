class StaticDataLancer

  BCA_ACCOUNT_NO = '1783055035'
  MANDIRI_ACCOUNT_NO = '126-000-997559-9'
  COMPANY_NAME = 'PT. Sribu Digital Kreatif'
  COMPANY_ADDRESS = 'The Maja, 2nd Floor. Jalan Kyai Maja 39, South Jakarta, Special Capital Region of Jakarta 12120, Indonesia'
  CALL_NUMBER_CALL_CENTER = '0804-1-177888'
  CALL_NUMBER_HUNTING = '+62 21 29305171'
  TEAM_EMAIL = 'ask@sribulancer.com'
  TEAM_EMAIL_NO_SPAM = 'ask[at]sribulancer.com'
  JOB_ORDER_PERCENTAGE_FEE = 10
  SERVICE_ORDER_PERCENTAGE_FEE = 10
  TASK_ORDER_PERCENTAGE_FEE = 0
  PPH_FEE = 3
  HELP_CENTER_URL = 'http://help.sribulancer.com/'
  BLOG_URL = 'http://blog.sribu.com/'
  WA_NUMBER = '+62-857-7992-3939'

  # share socmed sribulancer
  URL = 'https://www.sribulancer.com'
  TWITTER_SHARE_URL = 'https://twitter.com/intent/tweet?via=sribulancer&url='
  FACEBOOK_APP_ID = '1401884036776564'
  FACEBOOK_SHARE_URL = 'http://www.facebook.com/sharer.php?u='
  FACEBOOK_FEED_DIALOG_URL = 'https://www.facebook.com/dialog/feed?'
  FACEBOOK_REDIRECT_URI = 'https://www.sribulancer.com/id/window_close'
  FACEBOOK_THUMBNAIL_SHARE = 'https://sribulancer-production-sg.s3.amazonaws.com/assets/media/images/banner/facebook/share_facebook_600x315.png'
  LINKEDIN_SHARE_URL = 'http://www.linkedin.com/shareArticle?mini=true&url='

  TRUNCATE_JOB_DESCRIPTION = 200
  TRUNCATE_BIO_DESCRIPTION = 100
  TRUNCATE_RECRUITMENT_DESCRIPTION = 200

  TRUNCATE_SERVICE_TITLE = 55

  JOB = 'job'
  RECRUITMENT = 'recruitment'

  INBOUND_SEPARATOR = "--------- Write ABOVE THIS LINE to post a reply ---------"

  DIANA_NUMBER = "6285574671020"
  DIANA_WHATSAPP_NUMBER = "+6281286502844"

  class << self

    def display_bank_name(bank_acc)

      if bank_acc == BCA_ACCOUNT_NO
        return "BCA"
      elsif bank_acc == MANDIRI_ACCOUNT_NO
        return "Mandiri"
      else
        return "-"
      end
      
    end

    def get_elasticsearch_config
      config = {
        host: self.get_elasticsearch_url,
        transport_options: {
          request: { timeout: 5 }
        },
      }

      return config
    end

    def get_elasticsearch_url
      if Rails.env.production?
        url = "pollux:9200"
      elsif Rails.env.staging?
        url = "localhost:9200" # Still not understand why setup /etc/elasticsearch/elasticsearch.yml for network.host not working if pointed to "crux-pollux-staging"
      else
        url = "localhost:9200"
      end

      return url
    end

    def get_redis_url
      if Rails.env.production?
        url = "redis://pollux:6379"
      elsif Rails.env.staging?
        url = "redis://crux-pollux-staging:6379"
      else
        url = "redis://localhost:6379"
      end

      return url
    end
  end
  
end
