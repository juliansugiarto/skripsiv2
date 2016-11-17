module PageMetaHelper

  def portfolios_page_meta
    title = t('meta.portfolios.title_all')
    title = add_page_number(title)
    meta_description t('meta.portfolios.desc_all')

    page_title title

    return if params[:category_slug].blank? and params[:industry_slug].blank?

    category = titleize(params[:category_slug]) if params[:category_slug]
    industry = titleize(params[:industry_slug]) if params[:industry_slug]

    if category.present? and industry.present?
      title = I18n.t('meta.portfolios.title_cat_ind', cat: category, industry: industry)
      meta_description I18n.t('meta.portfolios.desc_cat_ind', cat: category, industry: industry)
    elsif category.present? and industry.blank?
      title = I18n.t('meta.portfolios.title_cat', cat: category)
      meta_description I18n.t('meta.portfolios.desc_cat', cat: category)
    elsif category.blank? and industry.present?
      title = I18n.t('meta.portfolios.title_ind', industry: industry)
      meta_description ""
    end

    page_title add_page_number(title)
  end

  def pricing_page_meta
    category = params[:category_slug].present? ? titleize(params[:category_slug]) : "Logo Design"
    page_title t('meta.pricing.title', :cat => category)
    meta_description t('meta.pricing.desc', :cat => category)
  end

  def store_show_page_meta
    cat_sub     = @store_item.sub_category.name[I18n.locale]
    item_number = @store_item.number
    info        = @store_item.info

    page_title t('meta.store_show.title', :cat_sub => cat_sub, :item_number => item_number)
    meta_description t('meta.store_show.desc', :info => info)
  end

  def browse_contests_page_meta
    cat     = (params[:category].present?) ? "" + titleize(params[:category]) : ""
    status  = (params[:status].present?) ? "" + (params[:status].gsub("_", " ")).capitalize : ""

    title = t('meta.browse_contests.title', :cat => cat, :status => status)

    page_title add_page_number(title)
    meta_description add_page_number(t("meta.browse_contests.desc", :cat => cat, :status => status))
  end

  def show_contest_overview_page_meta
    title = t('meta.overview_contest.title', :title => @contest.title)
    desc  = t('meta.overview_contest.desc',
              :username => @contest.owner.username,
              :total_design => @contest.entries_count,
              :category => @contest.category.name,
              :industry => @contest.industry.name,
              :title => @contest.title
            )

    page_title title
    # meta_description desc
  end

  def show_contest_gallery_page_meta
    title = t('meta.gallery_contest.title', :title => @contest.title, :cat => @contest.category.name)
    desc  = t('meta.gallery_contest.desc', :title => @contest.title)

    page_title title
    # meta_description desc
  end

  def show_contest_brief_page_meta
    title = t('meta.brief_contest.title', :title => @contest.title, :cat => @contest.category.name)
    desc  = t('meta.brief_contest.desc', :username => @contest.owner.username, :title => @contest.title)

    page_title title
    # meta_description desc
  end


  def show_contest_designers_page_meta
    title = t('meta.designers_contest.title', :title => @contest.title, :cat => @contest.category.name)
    desc  = t('meta.designers_contest.desc',
              :designers_count => @contest.participants_count,
              :username => @contest.owner.username,
              :title => @contest.title,
              :total_designs => @contest.entries_count,
              :duration => @contest.duration_requested
            )

    page_title title
    # meta_description desc
  end

  def show_contest_comments_page_meta
    title = t('meta.comments_contest.title', :title => @contest.title, :cat => @contest.category.name)
    desc  = t('meta.comments_contest.desc',
              :comments_count => @comments.count,
              :title => @contest.title
            )

    page_title title
    # meta_description desc
  end

  def show_contest_entries_page_meta
    title = t('meta.entries.title', :category => @contest.category.name,  :title => @contest.title, :designer => @entry.try(:owner).try(:username), :number => @entry.try(:contest_counter_id))

    page_title title
  end

  private
    def add_page_number(text = nil)
      text = "#{text} | #{I18n.t('meta.default.page', page: params[:page].to_i)}" if params[:page] and params[:page].to_i > 1
      text
    end

    def titleize(text = nil)
      text.titleize
    end

end
