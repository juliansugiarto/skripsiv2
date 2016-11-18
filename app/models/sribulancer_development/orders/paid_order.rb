class PaidOrder
  attr_reader :orders

  def initialize(orders)
    @orders = orders
  end

  def total
    freelancer_fees + fees + payment_codes
  end

  private

  def freelancer_fees
    orders.to_a.sum(&:freelancer_fee)
  end

  def fees
    orders.to_a.sum(&:fee)
  end

  def payment_codes
    orders.to_a.inject(0) { |sum, order| sum + payment_code(order) }
  end

  def payment_code(order)
    order.object.currency.code == 'IDR' ? order.payment_code : 0
  end
end
