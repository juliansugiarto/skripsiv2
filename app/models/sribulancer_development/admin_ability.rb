class AdminAbility
  include CanCan::Ability

  def initialize(member)
    
    if member.present?
      member.role.role_rules.each do |rr|
        rr.actions.each do |a|
          can a.to_sym, rr.name.classify.constantize
        end
      end
    end
  end
  
end
