class PaymentWorker
  include Sidekiq::Worker
  sidekiq_options retry: false

  def perform(options = {})
    send(options['perform'], options) if respond_to? options['perform']
  end

  def auto_confirm(options)
    order = Order.find options["order_id"]
    Payments::AutoConfirmService.new(order, options["trx"], options["type"]).go
  end

end