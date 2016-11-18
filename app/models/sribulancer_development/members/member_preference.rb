class MemberPreference
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Attributes::Dynamic
  include FullErrorMessages
  store_in database: 'sribulancer_development', collection: 'member_preferences'
  belongs_to :member

  # For Employer
  belongs_to :online_group_category, :foreign_key => 'online_group_category_id', index: true

  # For Freelancer
  belongs_to :online_category  
end
