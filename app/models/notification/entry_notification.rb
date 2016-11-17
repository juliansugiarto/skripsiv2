# ================================================================================
# Part:
# Desc:
# ================================================================================
class EntryNotification < Notification

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
    when "designer_runner_up"
      locale   = notified.locale
      contest  = self.entry.contest
      category = entry.contest.category
      ch       = entry.contest.owner
      MemberMailerWorker.perform_async(
        perform: :designer_runner_up,
        member_locale: locale,
        ch_username: ch.username,
        ch_email: ch.email,
        ch_url: members_profile_url(locale, ch.username),
        designer_username: notified.username,
        designer_email: notified.email,
        designer_url: members_profile_url(locale, notified.username),
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        contest_id: contest.id.to_s
      )

      TelegramWorker.perform_async(perform: 'send_telegram', text: "Runner Up Approved (#{contest.title}) ##{entry.contest_counter_id}")
    end
  end

end
