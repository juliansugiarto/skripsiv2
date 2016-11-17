module CommentHelper

  def process_comment(body = nil)

    usernames = extract_mentioned_screen_names body
    if usernames.present?
      Member.where(:username.in => usernames).each do |member|
        body.gsub!(
          "@#{member.username}", 
          link_to(
            "@#{member.username}",
            members_profile_url("id", member.username),
            :target => "_blank"
          )
        )
      end
    end

    design_ids = parse_hashtags body
    if design_ids.present?
      if @contest.present? and !@contest.is_confidential? and !@contest.is_private?
        @contest.entries.where(:contest_counter_id.in => design_ids).each do |entry|
          if !entry.withdrawed?
            body.gsub!(
              "##{entry.contest_counter_id}",
              link_to(
                "##{entry.contest_counter_id}",
                show_entry_url(I18n.locale, @contest.category.slug, @contest.slug, entry.id),
                :target => "_blank"
              )
            )
          end
        end
      end
    end

    return body
  end


  def parse_hashtags(comment)
    unless comment =~ /[##]/
      return []
    end

    tags = []
    comment.scan(/#[0-9]+/) do |before, hash, hash_text|
      match_data = $~
      text = match_data.to_s[1, match_data.to_s.length]
      tags << text
    end
    tags.each { |tag| yield tag } if block_given?
    tags
  end

end
