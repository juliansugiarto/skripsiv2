# Session helper
# Included on ApplicationController so method on this
# helper can be accessible on all layer
module SessionHelper

  def currency
    @currency ||= session[:currency].to_sym
    @currency.freeze
  end

  def current_member
    if session[:member_id].present?
      @current_member ||= Member.find(session[:member_id])
      # freeze current member to make it immutable (read only)
      @current_member.freeze
    else
      nil
    end
  end

  def is_logged_in?
    current_member.present?
  end

  def is_member_activated?
    current_member.is_activated?
  end

  def is_current_member_profile?(member = nil)
    return false if member.blank?
    current_member.present? ? current_member == member : false
  end

end
