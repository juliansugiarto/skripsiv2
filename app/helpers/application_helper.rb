module ApplicationHelper
  
  def get_url_content(url)
    Net::HTTP.get(URI.parse(URI.encode(url)))
  end

  def disable_search_engine?
    if Rails.env.staging? or
       (@contest.present? and @noindex == true) or
        controller_path == "labs"
      true
    else
      false
    end
  end

  def page_title(title = nil)
    if title
      # flush true means clear the content_for page_title first.
      content_for(:page_title, flush: true) { title[0...60] }
    else
      content_for?(:page_title) ? content_for(:page_title) : t('meta.default.title') # or default page title
    end
  end

  def meta_description(description = nil)
    # Better to have empty description rather than duplicate
    description = description[0..160] if description.present?
    content_for(:meta_description, flush: true) { h description }
  end

  # used to render meta keywords
  def meta_keywords(keywords = nil)
    if keywords and current_page?(root_path)
      content_for?(:meta_keywords) ? content_for(:meta_keywords) : t('meta.default.keywords') # or default meta keyword
    else
      content_for(:meta_keywords) { keywords }
    end
  end

  def meta_canonical?
    if (controller_name == "contests" and controller.action_name == "show") or
      (controller_name == "contests" and controller.action_name == "index" and params[:currency].present?) or
      (controller_name == "pricing" and controller.action_name == "index" and params[:currency].present?) or
      (controller_name == "profile" and controller.action_name == "show" and params[:currency].present?) or
      (controller_name == "portfolios" and controller.action_name == "index" and params[:currency].present?) or
      (controller_name == "stores" and controller.action_name == "index" and params[:currency].present?) or
      (controller_name == "categories" and controller.action_name == "show" or controller.action_name == "industry" and params[:currency].present?)
      true
    else
      false
    end
  end

  def admin_predefined_comment(object_comment = nil)
    body = object_comment[:body]

    case body
    when 'notifications.automatic.first_comment_in_open_contest'
      t(body)
    when 'notifications.automatic.edit_brief_notif'
      t(body,
        :created_at => object_comment[:created_at].to_time.strftime("%-d %b %Y, %H:%M"),
        :link_update_brief => show_contest_path(@contest.category.slug, @contest.slug, tab: :brief)
      )
    when 'notifications.automatic.private_upgraded'
      t(body)
    when 'notifications.automatic.package_upgraded'
      t(body,
        :package_name => @contest.package.name,
        :created_at => object_comment[:created_at].to_time.strftime("%-d %b %Y, %H:%M"),
        :prize => @contest.winners.first.prize
      )

    when 'notifications.automatic.extended'
      t(body,
        :end_date => @contest.end_date.to_time.strftime("%-d %b %Y, %H:%M")
      )
    when 'notifications.automatic.confidential_upgraded'
      t(body)
    else
      body
    end

  end



end
