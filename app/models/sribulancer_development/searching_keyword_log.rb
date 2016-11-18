class SearchingKeywordLog

  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'searching_keyword_logs'
  field :keyword

 end
 