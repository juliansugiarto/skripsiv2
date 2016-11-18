class TelegramWorker
  include Sidekiq::Worker
  include Rails.application.routes.url_helpers

  sidekiq_options retry: false

  TELEGRAM_SRIBUBOT_API           = ENV['TELEGRAM_SRIBUBOT_API']
  TELEGRAM_GROUP_ID_OPERATIONS    = ENV['TELEGRAM_GROUP_ID_OPERATIONS']

  def perform(options = {})
    send(options['perform'], options) if respond_to? options['perform'] and Rails.env.production?
  end

  def send_telegram(options)
    text = options['text']
    response = HTTParty.post(
      TELEGRAM_SRIBUBOT_API + '/sendMessage',
      body: {'text' => text, 'chat_id' => TELEGRAM_GROUP_ID_OPERATIONS, 'disable_web_page_preview' => true}
    )
  end

end
