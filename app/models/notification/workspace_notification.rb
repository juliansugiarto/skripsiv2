# ================================================================================
# Part:
# Desc:
# ================================================================================
class WorkspaceNotification < Notification

  #                                                                       Constant
  # ==============================================================================


  #                                                                  Attr Accessor
  # ==============================================================================

  #                                                                       Callback
  # ==============================================================================


  #                                                                          Field
  # ==============================================================================


  #                                                                       Relation
  # ==============================================================================
  belongs_to :workspace

  #                                                          Through Relationships
  # ==============================================================================
  # Since mongoid not provide "through relationships" like ActiveRecord, so we
  # use these method to provide "through relationships"
  # ==============================================================================


  #                                                                     Validation
  # ==============================================================================


  #                                                                   Class Method
  # ==============================================================================


  #                                                                         Method
  # ==============================================================================



  def notify
    case purpose
    when "ch_comment_file_transfer"
      locale   = notified.locale
      ch       = workspace.client
      contest  = workspace.contest
      category = contest.category

      MemberMailerWorker.perform_async(
        perform: :ch_comment_file_transfer,
        member_locale: locale,
        ch_username: ch.username,
        ch_email: ch.email,
        ch_url: members_profile_url(locale, ch.username),
        designer_username: notified.username,
        designer_email: notified.email,
        designer_url: members_profile_url(locale, notified.username),
        comment_body: workspace.events.last.body,
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        workspace_id: workspace.id.to_s
      )
    when "designer_comment_file_transfer"
      locale   = notified.locale
      designer = workspace.designer
      contest  = workspace.contest
      category = contest.category

      MemberMailerWorker.perform_async(
        perform: :designer_comment_file_transfer,
        member_locale: locale,
        ch_username: notified.username,
        ch_email: notified.email,
        ch_url: members_profile_url(locale, notified.username),
        designer_username: designer.username,
        designer_email: designer.email,
        designer_url: members_profile_url(locale, designer.username),
        comment_body: workspace.events.last.body,
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        workspace_id: workspace.id.to_s
      )
    when "designer_upload_file_master"
      locale   = notified.locale
      designer = workspace.designer
      contest  = workspace.contest
      category = contest.category

      MemberMailerWorker.perform_async(
        perform: :designer_upload_file_master,
        member_locale: locale,
        ch_username: notified.username,
        ch_email: notified.email,
        ch_url: members_profile_url(locale, notified.username),
        designer_username: designer.username,
        designer_email: designer.email,
        designer_url: members_profile_url(locale, designer.username),
        comment_body: workspace.events.last.body,
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        workspace_id: workspace.id.to_s
      )
    end
  end

end
