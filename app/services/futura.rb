class Futura
  def self.build
    new()
  end

  class << self

    def get_uid

    end

    def get_base_url
      if Rails.env.production?
        "https://sribu.com"
      else
        "http://localhost:4000"
      end
    end

    def get_endpoint(path="")
      buid.get_base_url + path
    end

  end
end
