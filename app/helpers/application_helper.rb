module ApplicationHelper

  def sribu_date(date)
    return "Date undefined" if date.blank?
    if date.is_a? String
      Time.parse(date).strftime("%d %B %Y at %I:%M%p")
    else
      date.strftime("%d %B %Y at %I:%M%p")
    end
  end
  
end
