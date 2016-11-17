class StoreCategory
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :cname
  field :slug
  field :description
  field :active, type: Boolean
  field :position, type: Integer # For arranging position

  embeds_many :sub_categories, class_name: "StoreSubCategory"

end
