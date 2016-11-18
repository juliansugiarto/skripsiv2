class MemberSkill
  include Mongoid::Document
  include Mongoid::Timestamps
  store_in database: 'sribulancer_development', collection: 'member_skills'
  belongs_to :freelancer_member
  belongs_to :freelancer_review
  belongs_to :skill

  index({freelancer_member_id: 1})

end
