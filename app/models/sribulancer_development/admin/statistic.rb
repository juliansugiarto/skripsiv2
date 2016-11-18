class Statistic

  include Mongoid::Document
  include Mongoid::Timestamps
  
  GROWTH_FILTER = %w(occurrence weekly monthly)
end
