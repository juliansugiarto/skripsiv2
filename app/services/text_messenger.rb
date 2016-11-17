class TextMessenger

  def self.build
    new()
  end

  class << self

    def send_otp(member)
      # Find number
      our_number = build.sender_number
      client_number = member.phone_books.desc(:created_at).first.try(:msisdn)
      raise if client_number.blank?

      # Create otp and save digest to database
      otp = build.generate_otp
      otp_digest = build.digest_generator(otp)

      member.update_attribute('otp', otp)
      member.update_attribute('otp_digest', otp_digest)
      member.update_attribute('otp_sent_at', Time.zone.now)

      # Start send message
      message = "Your authentication code is #{otp} for your request. Valid for 10 mins."

      # Disable Nexmo SMS
      # cloud = build.connect_cloud
      # send_meta = cloud.send_message(from: our_number, to: client_number, text: message)

      ZenzivaWorker.perform_async(perform: :send_sms, to: client_number, text: message)
      return true
    rescue
      return {}
    end


    # Resend verification code (with different code)
    def resend_otp(member)
      begin
        # Find number
        our_number = build.sender_number
        client_number = member.phone_books.desc(:created_at).first.try(:msisdn)
        raise if client_number.blank?
        # Find otp
        otp = member.otp
        member.update_attribute('otp_sent_at', Time.zone.now)

        # Start send message
        message = "Your authentication code is #{otp} for your request. Valid for 10 mins."

        ZenzivaWorker.perform_async(perform: :send_sms, to: client_number, text: message)
        return true
      rescue
        return {}
      end
    end


    def send_message(member, message)
      begin
        our_number = build.sender_number
        client_number = client_number = member.phone_books.find_by(default_number: true).try(:msisdn)
        raise if client_number.blank?

        # Start send message
        ZenzivaWorker.perform_async(perform: :send_sms, to: client_number, text: message)
        return true
      rescue
        return {}
      end
    end

  end

  def connect_cloud
    Nexmo::Client.new(key: ENV['NEXMO_KEY'], secret: ENV['NEXMO_SECRET'])
  end

  # Create digest
  def digest_generator(code)
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create(code, cost: cost)
  end

  # Generate 6 digits code
  def generate_otp
    rand(100000..999999)
  end

  def sender_number
    StaticData::NEXMO_NUMBER
  end

end
