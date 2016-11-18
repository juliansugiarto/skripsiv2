class EmployerReview < MemberReview
  belongs_to :employer_member
  belongs_to :workspace
end
