class MemberAbility
  include CanCan::Ability

  def initialize(member)
    # Define abilities for the passed in member here. For example:
    #
    member ||= Member.new # guest member (not logged in)
    if member.is_designer?
      can :manage, :all
    elsif member.is_contest_holder?
      can :manage, :all
      can :read, :all
    end
    #
    # The first argument to `can` is the action you are giving the member
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the member can perform the action on.
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the member can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/CanCanCommunity/cancancan/wiki/Defining-Abilities
  end
end
