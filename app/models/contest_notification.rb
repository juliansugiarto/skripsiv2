# ================================================================================
# Part:
# Desc:
# ================================================================================
class ContestNotification < Notification

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
  belongs_to :entry

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
    when "contest_winner_selected"
      locale   = notified.locale
      contest  = self.contest
      category = contest.category
      ch       = contest.owner
      MemberMailerWorker.perform_async(
        perform: :announcement_to_participants_after_winner_selected,
        member_locale: locale,
        ch_username: ch.username,
        ch_email: ch.email,
        ch_url: members_profile_url(locale, ch.username),
        designer_username: notified.username,
        designer_email: notified.email,
        designer_url: members_profile_url(locale, notified.username),
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug)
      )
    when "ch_contest_ending_in_2_days" 
      locale   = notified.locale
      contest  = self.contest
      category = contest.category
      ch       = contest.owner
      MemberMailerWorker.perform_async(
        perform: :ch_contest_ending_in_2_days,
        member_locale: locale,
        ch_username: ch.username,
        ch_email: ch.email,
        ch_url: members_profile_url(locale, ch.username),
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        contest_id: contest.id.to_s
      )
    when "ch_winner_pending_deadline_in_1_day" 
      locale   = notified.locale
      contest  = self.contest
      category = contest.category
      ch       = contest.owner
      MemberMailerWorker.perform_async(
        perform: :ch_winner_pending_deadline_in_1_day,
        member_locale: locale,
        ch_username: ch.username,
        ch_email: ch.email,
        ch_url: members_profile_url(locale, ch.username),
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        contest_id: contest.id.to_s
      )
    when "ch_winner_pending_deadline_in_3_days"
      locale   = notified.locale
      contest  = self.contest
      category = contest.category
      ch       = contest.owner
      MemberMailerWorker.perform_async(
        perform: :ch_winner_pending_deadline_in_3_days,
        member_locale: locale,
        ch_username: ch.username,
        ch_email: ch.email,
        ch_url: members_profile_url(locale, ch.username),
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        contest_id: contest.id.to_s
      )
    when "designer_contest_ending_in_2_days"
      locale   = notified.locale
      contest  = self.contest
      category = contest.category
      ch       = contest.owner
      designer = notified
      MemberMailerWorker.perform_async(
        perform: :ch_winner_pending_deadline_in_3_days,
        member_locale: locale,
        ch_username: ch.username,
        ch_email: ch.email,
        ch_url: members_profile_url(locale, ch.username),
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        contest_id: contest.id.to_s,
        designer_username: designer.username,
        designer_email: designer.email
      )
    when "designer_contest_ending_in_24_hours"
      locale   = notified.locale
      contest  = self.contest
      category = contest.category
      ch       = contest.owner
      designer = notified
      MemberMailerWorker.perform_async(
        perform: :ch_winner_pending_deadline_in_3_days,
        member_locale: locale,
        ch_username: ch.username,
        ch_email: ch.email,
        ch_url: members_profile_url(locale, ch.username),
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        contest_id: contest.id.to_s,
        designer_username: designer.username,
        designer_email: designer.email
      )
    when "designer_brief_updated"
      locale   = notified.locale
      contest  = self.contest
      category = contest.category
      ch       = contest.owner
      designer = notified
      MemberMailerWorker.perform_async(
        perform: :designer_brief_updated,
        member_locale: locale,
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        contest_id: contest.id.to_s,
        designer_username: designer.username,
        designer_email: designer.email
      )
    end

  end

end
