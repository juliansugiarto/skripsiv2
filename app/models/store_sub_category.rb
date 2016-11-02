class StoreSubCategory
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name
  field :cname
  field :slug
  field :description
  field :active, type: Boolean

  field :license # berisi hash fee dan komisi designer untuk pembelian license (default 40%)
  field :revision # berisi hash fee dan komisi designer untuk revision (default 80%)

  embedded_in :store_category, inverse_of: :sub_categories

end
