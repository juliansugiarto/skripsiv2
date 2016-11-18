class Elasticsearch::Member

  def self.last_order(member_id, obj)
    if obj.class == Job
      job_application = JobApplication.find_by(member_id: member_id, job: obj)
      return nil if job_application.blank? or job_application.orders.blank?
      job_application.orders.created_at_desc.first
    elsif obj.class == Service
      return nil if obj.orders.blank?
      obj.orders.created_at_desc.first
    else
      return nil
    end
  end

  def self.last_hired(member_id, obj)
    if obj.class == Job
      last_order = last_order(member_id, obj)

      if last_order
        return last_order.created_at
      else
        return nil
      end
    elsif obj.class == Service
      last_order = last_order(member_id, obj)

      if last_order
        return last_order.created_at
      else
        return nil
      end
    else
      return nil
    end
  end

  def self.is_online?(member)
    if member.last_activity.present?
      last_activity = DateTime.parse(member.last_activity.to_s)
      if (last_activity + 5.minutes) > DateTime.now
        return ['color-green', "#{member.username} is online"]
      elsif (last_activity + 10.minutes) > DateTime.now
        return ['color-yellow', "#{member.username} is away"]
      else
        return ['color-gray', "#{member.username} is offline"]
      end
    else
      return ['color-gray', "#{member.username} is offline"]
    end
  end

  def self.prefered_languages_display(member)
    text = ""
    if member.prefered_languages.present?
      text = member.prefered_languages.map{|pl| "<span class=''>#{pl.name}</span>"}.join(', ')
    else
      text = "-"
    end
    text
  end

end