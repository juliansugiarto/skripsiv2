# class used to determine access/credentials for super, config and general member
class Ability
  include CanCan::Ability

  def initialize(member)
    # no user given then use Member object as anonymous
    member ||= MemberLancer.new

    if member.employer?
      can :manage, Service
      can :manage, Task
      cannot [:new, :new_details, :new_details_for_private, :new_confirm, :new_confirm_for_private, :create, :edit, :update], Service

      can :manage, Job
      can :manage, JobOffer
      can :manage, JobApplication
      cannot [:new, :create, :edit, :update], JobApplication

      can :manage, Recruitment
      can :manage, RecruitmentApplication
      cannot [:new, :create, :edit, :update], RecruitmentApplication

      can :manage, Order
      can :manage, Package

      can :manage, Chat
    elsif member.freelancer?
      can :manage, Job
      cannot [:new, :new_details, :new_details_for_private, :new_confirm, :create, :edit, :update], Job

      can :manage, Service

      can :manage, JobApplication

      can :manage, Recruitment
      cannot [:new, :new_details, :new_confirm, :create, :edit, :update], Recruitment

      can :manage, RecruitmentApplication
      can [:index, :show, :hide, :create_message_event, :mark_as_archive, :mark_as_archive_delete, :unarchive], Chat
      cannot [:new_from_service, :new_from_job, :new_from_recruitment, :create_from_recruitment, :new_from_task], Chat

    elsif member.service_provider?
      cannot [:new, :new_details, :new_details_for_private, :new_confirm, :new_confirm_for_private, :create, :edit, :update], Service

      can :manage, Task
      cannot [:new, :new_details, :new_details_for_private, :new_confirm, :create, :edit, :update], Task

      can :manage, JobOffer
      can :manage, TaskApplication

      can [:index, :show, :hide, :create_message_event, :mark_as_archive, :unarchive], Chat
    else
      can :create, JobOffer
      can [:create, :show, :new, :new_details, :new_details_v2, :create_and_register_member, :persist_job_in_session], Job
      can [:show, :new, :new_details, :new_details_v2, :new_details_for_private, :new_confirm, :new_confirm_v2, :new_confirm_for_private, :create_and_register_member, :persist_task_in_session], Task
      can [:show, :new, :new_details, :new_confirm, :create_and_register_member, :persist_recruitment_in_session], Recruitment
      can [:show, :new, :new_details, :new_confirm, :create_and_register_member, :persist_service_in_session], Service
      can :show, Member
      can [:index, :voffice], Package
    end
  end
end
