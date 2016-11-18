# represent a job posted by employer member
class OrderStatus

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'order_statuses'
  INITIATED = 'initiated'
  REJECTED = 'rejected'
  PAID = 'paid'
  CANCEL = 'cancel'
  NO_HIRE = 'not_hire'
  REFUNDED = 'refunded'

  field :cname

  validates :cname, presence: true, :uniqueness => true

  def self.get_initiated
    OrderStatus.where(:cname => INITIATED).first
  end

  def self.rejected
    OrderStatus.where(:cname => REJECTED).first
  end

  def self.get_paid
    OrderStatus.where(:cname => PAID).first
  end

  def self.get_cancel
    OrderStatus.where(:cname => CANCEL).first
  end

  def self.get_refunded
    OrderStatus.where(:cname => REFUNDED).first
  end

end
