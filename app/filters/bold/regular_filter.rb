# Filter for backoffice
module Bold
  class RegularFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(class_name, arg, inject_arg)
        morph_obj = Object.const_get class_name
        sort_column = arg[:sort_by] || 'created_at'
        sort_direction = %w[asc desc].include?(arg[:direction]) ? arg[:direction] : 'desc'
        if inject_arg[:use].present? && inject_arg[:use] == 'any_in'
          queried_instances = morph_obj.any_in(inject_arg[:use_params]).where(build.initial_query(class_name, {}, arg)).order(sort_column + ' ' + sort_direction)
        else
          queried_instances = morph_obj.where(build.initial_query(class_name, inject_arg, arg)).order(sort_column + ' ' + sort_direction)
        end

        if arg[:spesific_search].present?
          queried_instances = build.spesific_search(queried_instances, class_name, arg)
          queried_instances = queried_instances.where(build.initial_query(class_name, inject_arg, arg)).order(sort_column + ' ' + sort_direction)
        end

        # Run more filters
        return build.filter(arg, queried_instances)
      end

    end


    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, queried_instances)
      total_queried_instances = 0
      begin
        total_queried_instances = queried_instances.count

        if queried_instances.kind_of?(Array)
          queried_instances = Kaminari.paginate_array(queried_instances).page(arg[:page]).per(arg[:per])
        else
          queried_instances = queried_instances.page(arg[:page]).per(arg[:per])
        end

      rescue
        queried_instances = []
        total_queried_instances = 0
      end

      return queried_instances, total_queried_instances
    end

    # Boost query, anything can filter first goes here
    def initial_query(class_name, inject_arg, arg)
      query = Hash.new

      if arg[:from].present? and arg[:to].present?
        from = Time.parse(arg[:from])
        to = Time.parse(arg[:to]).end_of_day
        query[:created_at] = from..to
      end

      if Ticket.types.include?(class_name) || class_name == 'Ticket'
        unless arg.key?(:member_id) || arg.key?(:lead_id) || arg.key?(:contest_id)
          if arg[:status].present?
            query[:status] = TicketStatus.find_by(cname: arg[:status])
          else
            query[:status] = TicketStatus.open
          end

          if arg[:assigned_user_id].present?
            user = User.find(arg[:assigned_user_id])
            query[:assigned_to] = user if user.present?
          end
        end
      end

      if class_name == 'Exam'
        query[:approved] = inject_arg[:approved]
      end

      query.reverse_merge!(inject_arg) if inject_arg.kind_of?(Hash) unless arg[:spesific_search].present?
      return query
    end


    def spesific_search(queried_instances, class_name, arg)
      if Ticket.types.include?(class_name) || class_name == 'Ticket'
        hash = JSON.parse arg[:spesific_search]
        if hash["target"].present? && hash["query"].present?
          regexp = Regexp.new(hash["query"], true)
          case hash["target"]
          when "type"
            return Ticket.inquiry.where(_type: regexp) if hash["group"] == 'inquiry'
            return Ticket.where(_type: regexp) if hash["group"] == 'myticket' || hash["group"] == 'pending' || hash["group"] == 'solved'
            return Ticket.upgrade.where(_type: regexp) if hash["group"] == 'upgrade'
            return Ticket.happiness.where(_type: regexp) if hash["group"] == 'happiness'
          when "member_username_or_name"
            username_match_ch = Member.client.where(username: regexp).pluck(:id)
            name_match_ch = Member.client.where(name: regexp).pluck(:id)
            name_match_lead = Lead.where(name: regexp).pluck(:id)
            match_entity = username_match_ch + name_match_ch + name_match_lead
            match_entity.uniq
            return Ticket.inquiry.where(:created_for.in => match_entity) if hash["group"] == 'inquiry'
            return Ticket.unpaid.where(:created_for.in => match_entity) if hash["group"] == 'unpaid'
            return Ticket.upgrade.where(:created_for.in => match_entity) if hash["group"] == 'upgrade'
            return Ticket.happiness.where(:created_for.in => match_entity) if hash["group"] == 'happiness'
            return Ticket.where(:created_for.in => match_entity) if hash["group"] == 'myticket' || hash["group"] == 'pending' || hash["group"] == 'solved'
          when "email"
            email_match_ch = Member.client.where(email: regexp).pluck(:id)
            if hash["group"] == 'inquiry' || hash["group"] == 'myticket' || hash["group"] == 'pending' || hash["group"] == 'solved'
              email_match_lead = Lead.where(email: regexp).pluck(:id)
              match_entity = email_match_lead + email_match_ch
              match_entity.uniq
            end
            return Ticket.inquiry.where(:created_for.in => match_entity) if hash["group"] == 'inquiry'
            return Ticket.unpaid.where(:created_for.in => email_match_ch) if hash["group"] == 'unpaid'
            return Ticket.upgrade.where(:created_for.in => email_match_ch) if hash["group"] == 'upgrade'
            return Ticket.happiness.where(:created_for.in => email_match_ch) if hash["group"] == 'happiness'
            return Ticket.where(:created_for.in => match_entity) if hash["group"] == 'myticket' || hash["group"] == 'pending' || hash["group"] == 'solved'
          when "assigned_to"
            # TODO: assign to no one search
            username_match_user = User.where(username: regexp).pluck(:id)
            return Ticket.inquiry.where(:assigned_to.in => username_match_user) if hash["group"] == 'inquiry'
            return Ticket.unpaid.where(:assigned_to.in => username_match_user) if hash["group"] == 'unpaid'
            return Ticket.upgrade.where(:assigned_to.in => username_match_user) if hash["group"] == 'upgrade'
            return Ticket.happiness.where(:assigned_to.in => username_match_user) if hash["group"] == 'happiness'
            return Ticket.where(:assigned_to.in => username_match_user) if hash["group"] == 'pending' || hash["group"] == 'solved'
          when "priority"
            priority_match = TicketPriority.where(cname: regexp).pluck(:id)
            return Ticket.inquiry.where(:priority.in => priority_match) if hash["group"] == 'inquiry'
            return Ticket.unpaid.where(:priority.in => priority_match) if hash["group"] == 'unpaid'
            return Ticket.happiness.where(:priority.in => priority_match) if hash["group"] == 'happiness'
            return Ticket.where(:priority.in => priority_match) if hash["group"] == 'myticket' || hash["group"] == 'pending' || hash["group"] == 'solved'
          when "contest"
            contest_match = Contest.where(title: regexp).pluck(:id)
            return Ticket.unpaid.where(:contest_id.in => contest_match) if hash["group"] == 'unpaid'
            return Ticket.upgrade.where(:contest_id.in => contest_match) if hash["group"] == 'upgrade'
            return Ticket.happiness.where(:contest_id.in => contest_match) if hash["group"] == 'happiness'
          when "contest_status"
            contest_status_match = ContestStatus.where(name: regexp).pluck(:id)
            contest_match = Contest.where(:status.in => contest_status_match).pluck(:id)
            return Ticket.unpaid.where(:contest_id.in => contest_match) if hash["group"] == 'unpaid'
          when "invoice_number"
            invoice_match = Invoice.where(number: regexp).pluck(:id)
            return Ticket.upgrade.where(:invoice_id.in => invoice_match) if hash["group"] == "upgrade"
          when "invoice_status"
            invoice_status_match = InvoiceStatus.where(cname: hash["query"].downcase).pluck(:id)
            invoice_match = Invoice.where(:status.in => invoice_status_match).pluck(:id)
            return Ticket.upgrade.where(:invoice_id.in => invoice_match) if hash["group"] == 'upgrade'
          end
        end
        return queried_instances
      elsif class_name == 'Lead'
        hash = JSON.parse arg[:spesific_search]
        if hash["target"].present? && hash["query"].present?
          regexp = Regexp.new(hash["query"], true)
          case hash["target"]
          when "name"
            return Lead.where(name: regexp)
          when "email"
            return Lead.where(email: regexp)
          when "phone"
            return Lead.where(phone_number: regexp)
          when "created_by"
            return Lead.where(created_by: regexp)
          when "location"
            return Lead.where(location: regexp)
          when "utm_source"
            return Lead.where(utm_source: regexp)
          when "note"
            return Lead.where(note: regexp)
          end
        end
        return queried_instances
      elsif class_name == 'Exam'
        hash = JSON.parse arg[:spesific_search]
        if hash["target"].present? && hash["query"].present?
          regexp = Regexp.new(hash["query"], true)
          case hash["target"]
          when "username"
            match_entity = Member.designer.where(username: regexp).pluck(:id)
            return Exam.where(:owner_id.in => match_entity)
          when "email"
            match_entity = Member.designer.where(email: regexp).pluck(:id)
            return Exam.where(:owner_id.in => match_entity)
          when "category"
            return Exam.where(category: regexp)
          end
        end
      end

    end

    # Regexp Matcher
    def is_req_match(objects, matcher)
      objects.each do |o|
        return true if Object.const_get(o).pluck(:name).uniq.join(' ').match(matcher).present?
      end
      return false
    end

  end
end
