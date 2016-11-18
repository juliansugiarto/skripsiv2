class ZenzivaWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    send(options['perform'], options) if (respond_to? options['perform']) and Rails.env.production? and Setting.is_using_zenziva?
  end

  def send_sms(options)
    Zenziva.send_sms(options['to'], options['text'])
  end

end