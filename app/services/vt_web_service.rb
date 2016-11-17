class VtWebService

  def initialize(invoice_id)
    @invoice = Invoice.find invoice_id
  end

  def build_payment
    body = default_values
    body.merge!(vt_web_only)

    if @invoice._type == "StoreInvoice"
      body.merge!(transactions_store)
    else
      body.merge!(transactions)
    end
    auth = {:username => VT_SETTING['server_key'], :password => ""}
    result = HTTParty.post(
      VT_SETTING['charge'],
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'},
      :basic_auth => auth,
      :body => body.to_json
    )

    Rails.logger.info "********* Start - VT WEB *********\n#{result}\n\n\n#{body}\n********* END - VT WEB *********" if Rails.env.development?
    result["redirect_url"]
  end

  private

  def default_values
    {
      payment_type: "VTWEB"
    }
  end

  def vt_web_only
    {
      vtweb: {
        credit_card_3d_secure: true,
        enabled_payments: ["credit_card"]
      }
    }
  end

  def transactions
    po_code     = @invoice.number.truncate(17, omission: '').tr('^A-Za-z0-9', '').to_s + ('A'..'Z').to_a.shuffle.join[0..1].to_s
    order_id    = "SRI#{po_code}"

    # Filter contest name with regex '^A-Za-z0-9 ' , hanya boleh A-Z, a-z, angka dan SPASI
    price_original = @invoice.calculate_remains - @invoice.unique_code
    title = @invoice.contest.title.to_s.truncate(45, omission: '').tr('^A-Za-z0-9 ', '')
    cc_fee = @invoice.cc_fee_only

    commodities = []
    commodities << build_commodity("Title", price_original, 1, title)
    commodities << build_commodity('CCFee', cc_fee, 1, 'CC Processing Fee')

    {
      transaction_details: {
        order_id: order_id,
        gross_amount: @invoice.for_vt.to_i
      },
      item_details: commodities
    }
  end

  def transactions_store
    po_code     = @invoice.number.truncate(17, omission: '').tr('^A-Za-z0-9', '').to_s + ('A'..'Z').to_a.shuffle.join[0..1].to_s
    order_id    = "SRI#{po_code}"

    # Filter contest name with regex '^A-Za-z0-9 ' , hanya boleh A-Z, a-z, angka dan SPASI
    price_original = @invoice.calculate_remains - @invoice.unique_code
    title = "Sribu Store"
    cc_fee = @invoice.cc_fee_only

    commodities = []
    commodities << build_commodity("Title", price_original, 1, title)
    commodities << build_commodity('CCFee', cc_fee, 1, 'CC Processing Fee')

    {
      transaction_details: {
        order_id: order_id,
        gross_amount: @invoice.for_vt
      },
      item_details: commodities
    }
  end

  def build_commodity(name, price, quantity, description = name)
    {
      'id'        => name,
      'price'     => price.to_i,
      'quantity'  => quantity,
      'name'      => description
    }
  end
end
