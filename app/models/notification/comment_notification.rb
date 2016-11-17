# ================================================================================
# Part:
# Desc:
# ================================================================================
class CommentNotification < Notification
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
  belongs_to :comment
  belongs_to :entry
  belongs_to :participation
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
    when "ch_comment_entry"
      locale   = notified.locale
      comment  = self.comment
      entry    = Entry.find comment.commentable_id
      contest  = entry.contest
      category = contest.category
      MemberMailerWorker.perform_async(
        perform: :ch_comment_entry,
        member_locale: locale,
        ch_username: comment.author.username,
        ch_email: comment.author.email,
        ch_url: members_profile_url(locale, comment.author.username),
        designer_username: notified.username,
        designer_email: notified.email,
        designer_url: members_profile_url(locale, notified.username),
        comment_body: comment.body,
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        contest_counter_id: entry.contest_counter_id,
        entry_url: show_entry_url(locale, category.slug, contest.slug, entry.id.to_s, entry.contest_counter_id)
      )
    when "designer_comment_entry"
      locale   = notified.locale
      comment  = self.comment
      entry    = Entry.find comment.commentable_id
      contest  = entry.contest
      category = contest.category
      MemberMailerWorker.perform_async(
        perform: :designer_comment_entry,
        member_locale: locale,
        ch_username: notified.username,
        ch_email: notified.email,
        ch_url: members_profile_url(locale, notified.username),
        designer_username: comment.author.username,
        designer_email: comment.author.email,
        designer_url: members_profile_url(locale, comment.author.username),
        comment_body: comment.body,
        contest_title: contest.title,
        contest_url: show_contest_url(locale, category.cname, contest.slug),
        contest_counter_id: entry.contest_counter_id,
        entry_url: show_entry_url(locale, category.slug, contest.slug, entry.id.to_s, entry.contest_counter_id)
      )
    end
  end

end
