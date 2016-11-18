class Portfolio

	include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'portfolios'
  field :url
  field :title
  field :image
  field :package_group_cname
  mount_uploader :image, PortfolioUploader
  
  belongs_to :member
  belongs_to :online_group_category

end
