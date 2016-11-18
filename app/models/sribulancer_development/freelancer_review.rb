class FreelancerReview < MemberReview
  has_many :member_skill
  belongs_to :workspace
end
