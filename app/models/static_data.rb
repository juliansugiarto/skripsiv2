class StaticData
  NEXMO_NUMBER = '6285574671175'

  class << self

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
        url = 'banner:9200'
      elsif Rails.env.staging?
        url = "rockwell-staging-1:9200"
      else
        url = "localhost:9200"
      end

      return url
    end

  end
end
