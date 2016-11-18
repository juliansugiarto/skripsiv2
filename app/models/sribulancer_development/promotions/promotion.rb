class Promotion
  
  include Mongoid::Document
  include Mongoid::Timestamps
  include FullErrorMessages
  store_in database: 'sribulancer_development', collection: 'promotions'
  include ActionView::Helpers::NumberHelper
  
  field :title
  field :description
  field :start_date, type: DateTime
  field :expired_date, type: DateTime
  field :voucher_type
  field :voucher_value, type: Float
  field :minimal_budget, type: Float
  field :universal, type: Boolean, default: true
  field :quantity
  field :active, type: Boolean, default: true
  field :apply_to_packages, type: Boolean, default: false

  embeds_many :promotion_code

  has_and_belongs_to_many :categories

  scope :created_at_desc, -> {desc(:created_at)}
  scope :active_only, -> {where(active: true)}
  scope :not_expired, -> {where(:start_date.lt => DateTime.now, :expired_date.gte => Time.now.beginning_of_day)}

  def voucher_value_display(order=nil)
    if self.voucher_type == 'Nominal'
      "#{number_to_currency(self.voucher_value, unit: '', precision: 0)}"
    else
      if order.nil?
        "#{number_to_percentage(self.voucher_value, precision: 0)}"
      else
        "#{number_to_currency(order.budget * (self.voucher_value/100), unit: '', precision: 0) } (#{number_to_percentage(self.voucher_value, precision: 0)})"
      end
      
    end

  end

end
