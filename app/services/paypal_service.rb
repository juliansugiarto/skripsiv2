class PaypalService
  include ApplicationHelper
  include Rails.application.routes.url_helpers

  def initialize(invoice_id, controller)
    @view_context = controller.view_context
    @invoice      = Invoice.find invoice_id
    @member       = @invoice.owner
  end

  def build_payment
    values = build_invoice
    paypal_url + values.to_param
  end

  private

  def build_invoice
    if @invoice._type == "StoreInvoice"
      description = "[Sribu] Store Purchase"
    else
      description = "[Sribu] Contest Order Purchase"
    end

    options = {
      invoice: @invoice.number,
      description: description,
      return_url: set_return_paypal_url,
      cancel_url: set_cancel_paypal_url
    }

    options.merge!(default_values)
    options.merge!(build_commodity(1, description, @invoice.to_usd.to_i, 1, @invoice.number))
    options
  end

  def default_values
    {
      business: ENV['PAYPAL_MERCHANT_EMAIL'],
      cmd: '_cart',
      upload: 1,
      rm: 2,
      currency_code: 'USD'
    }
  end

  def build_commodity(index, item_name, amount, quantity, item_number = nil)
    commodity = {
      "item_name_#{index}"   => item_name,
      "amount_#{index}"      => amount,
      "quantity_#{index}"    => quantity
    }
    if item_number.present?
      commodity.merge!("item_number_#{index}" => item_number)
    end
    commodity
  end


  def exchange_to_usd(value)
    Money.new(value, "IDR").exchange_to("USD").to_s
  end

  def paypal_url
    "https://www.paypal.com/cgi-bin/webscr?"
  end

  def set_return_paypal_url
    # token = Digest::MD5::hexdigest(@invoice.po_code + @invoice.created_at.to_s)
    # @view_context.thank_you_paypal_store_index_url(:id => @invoice.id, :token =>token)
    root_url + 'payments/thank-you?invoice_id=' + @invoice.id.to_s
  end

  def set_cancel_paypal_url
    root_url + 'payments/select-payment?invoice_id=' + @invoice.id.to_s + '&status=cancel'
  end

end
