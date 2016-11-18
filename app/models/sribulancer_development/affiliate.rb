# represent a affiliate
class Affiliate

  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :code

  validates :name, presence: true
  validates :code, presence: true, :uniqueness => true

end
