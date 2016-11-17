class VtDirectService

  def initialize(invoice_id, params)
    @invoice = Invoice.find invoice_id
    @vt_token = params[:hidden_vt_token]
  end

  def build_payment
    # Generate Body
    body = default_values
    body.merge!(credit_card_details)

    if @invoice._type == "StoreInvoice"
      body.merge!(transactions_store)
    else
      body.merge!(transactions)
    end

    body.merge!(customer_details)

    auth = {:username => VT_SETTING['server_key'], :password => ""}
    trx = HTTParty.post(
      VT_SETTING['charge'],
      :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json'},
      :basic_auth => auth,
      :body => body.to_json
    )
    Rails.logger.info "********* Start - VT DIRECT *********\n#{trx}\n\n\n#{body}\n********* END - VT DIRECT *********" if Rails.env.development?
    trx
  end


  private

  def default_values
    {
      payment_type: "credit_card"
    }
  end

  def credit_card_details
    {
      credit_card: {
        token_id: @vt_token
      }
    }
  end

  def transactions
    po_code     = @invoice.number.truncate(17, omission: '').tr('^A-Za-z0-9', '').to_s + ('A'..'Z').to_a.shuffle.join[0..1].to_s
    order_id    = VT_SETTING['order_prefix']+po_code

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
        gross_amount: @invoice.for_vt
      },
      item_details: commodities
    }
  end

  def transactions_store
    po_code     = @invoice.number.truncate(17, omission: '').tr('^A-Za-z0-9', '').to_s + ('A'..'Z').to_a.shuffle.join[0..1].to_s
    order_id    = VT_SETTING['order_prefix']+po_code

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

  def customer_details
    member = @invoice.owner
    first_name = member.username.tr('^A-Za-z', '')
    email = member.email
    phone = sanitize_contact_number(@invoice.owner.phone_books.first.contact_number)
    {
      "customer_details" => {
        "first_name" => first_name,
        "last_name" => "default last name",
        "email" => email,
        "phone" => phone,
        "billing_address" => {
          "first_name" => first_name,
          "last_name" => "default last name",
          "address" => "default address1",
          "city" => "default city",
          "postal_code" => "12345",
          "phone" => phone,
          "country_code" => "IDN"
        }
      }
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

  def sanitize_contact_number(contact)
    contact = ('0'..'9').to_a.shuffle.join[0..8] if contact.blank? || (contact.present? and contact.strip=="")
    contact = contact.tr('^0-9', '')
    contact = contact + ('0'..'9').to_a.shuffle.join[0..5].to_s if contact.length<=5

    return contact
  end

end
