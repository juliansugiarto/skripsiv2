# represent category for job and service
class CategoryLancer

  include Mongoid::Document
  include Mongoid::Timestamps

  include Elasticsearch::Model
  include Elasticsearch::Model::Serializing
  include Elasticsearch::Model::Callbacks

  store_in database: 'sribulancer_development', collection: 'categories'
  # include this module to provide calling link_to method inside model
  include ActionView::Helpers

  field :cname
  field :minimum_budget, type: Float

  field :name, type: Hash, default: {}
  field :name_seo, type: Hash, default: {}
  field :work_scope, type: Hash, default: {}

  field :placeholder_title, type: Hash, default: {}
  field :placeholder_description, type: Hash, default: {}

  # For Home V2 purpose
  field :keywords, type: Hash, default: {}

  # short ID to be used in URL for seo
  field :sid, type: Integer

  field :active, type: Boolean, default: true

  validates :cname, presence: true, :uniqueness => true
  # validates :group_category, presence: true

  belongs_to :currency, :class_name => "Currency", :foreign_key => 'minimum_budget_currency_id'

  scope :active_only, -> {where(active: true)}
  scope :cname_asc, -> {asc(:cname).where(active: true)}

  before_create :set_sid

end
