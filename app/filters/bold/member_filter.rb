# Filter for backoffice
module Bold
  class MemberFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        sort_column = arg[:sort_by] || 'created_at'
        sort_direction = %w[asc desc].include?(arg[:direction]) ? arg[:direction] : 'desc'
        members = Member.where(build.initial_query(arg)).order(sort_column + ' ' + sort_direction)
        # Run more filters

        if arg[:quick_search].present?
          members = build.quick_search(arg)
          members = members.where(build.initial_query(arg)).order(sort_column + ' ' + sort_direction)
        end

        if arg[:spesific_search].present?
          members = build.spesific_search(members, arg)
          members = members.where(build.initial_query(arg)).order(sort_column + ' ' + sort_direction)
        end

        return build.filter(arg, members)

      end

    end

    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, members)
      total_members = 0
      begin

        if arg[:purpose].present?
          case arg[:purpose]
          when "reported"
            member_reports = MemberReport.all
            members = members.any_in(id: member_reports.map(:reported_id))
            # members = members.any_of({"id" => { "$in" => member_reports.map(:reported_id)}})
          when "banned"
            members = members.where(banned: true)
          when "warned"
          else
          end
        end

        if arg[:member].present?
          query_contact_number = {contact_number: arg[:member]}
          query_username = {username: Regexp.new("#{Regexp.escape(arg[:member])}")}
          query_email = {email: Regexp.new("#{Regexp.escape(arg[:member])}")}
          members = members.any_of(query_contact_number, query_username, query_email)
        end

        total_members = members.count

        if members.kind_of?(Array)
          members = Kaminari.paginate_array(members).page(arg[:page]).per(arg[:per])
        else
          members = members.page(arg[:page]).per(arg[:per])
        end

      rescue
        members = []
        total_members = 0
      end

      return members, total_members
    end

    def quick_search(arg)
      # for quick search by contest Username, Email, Name
      if arg[:quick_search].present?

        members_response = Member.client.search(query: {
          query_string: {
            query: '*'+arg[:quick_search]+'*',
            fields: ["username", "email", "name"],
            default_operator: "AND"
          }
        })

        members = members_response.per(members_response.results.total).records

        mt = MemberType.find_by(cname: arg[:type])
        members = members.where(member_type: mt)

      end
    end

    def spesific_search(members, arg)
      hash = JSON.parse arg[:spesific_search]
      if hash["target"].present? && hash["query"].present?
        regexp = Regexp.new(hash["query"], true)
        case hash["target"]
        when "username"
          members = Member.client.where(username: regexp) if hash["group"] == 'contest_holder'
          members = Member.designer.where(username: regexp) if hash["group"] == 'designer'
          return members
        when "email"
          members = Member.client.where(email: regexp) if hash["group"] == 'contest_holder'
          members = Member.designer.where(email: regexp) if hash["group"] == 'designer'
          return members
        when "phone"
          #TODO: use phone_books
          members = Member.client.where(phone: regexp) if hash["group"] == 'contest_holder'
          members = Member.designer.where(phone: regexp) if hash["group"] == 'designer'
          return members
        when "country"
          members = Member.client.where(location: regexp) if hash["group"] == 'contest_holder'
          members = Member.designer.where(location: regexp) if hash["group"] == 'designer'
          return members
        when "utm_source"
          members = Member.client.where(utm_source: regexp) if hash["group"] == 'contest_holder'
          members = Member.designer.where(utm_source: regexp) if hash["group"] == 'designer'
        end
      end
      return members
    end

    # Boost query, anything can filter first goes here
    def initial_query(arg)
      query = Hash.new
      query[:member_type_id] = MemberType.find_by(cname: arg[:type]).try(:id) if arg[:type].present?
      query[:username] = Regexp.new("#{Regexp.escape(arg[:username])}") if arg[:username].present?
      query[:email] = Regexp.new("#{Regexp.escape(arg[:email])}") if arg[:email].present?
      query[:utm_source] = Regexp.new("#{Regexp.escape(arg[:utm_source])}") if arg[:utm_source].present?

      if arg[:from].present? and arg[:to].present?
        from = Time.parse(arg[:from])
        to = Time.parse(arg[:to]).end_of_day
        query[:created_at] = from..to
      end

      return query
    end
  end
end
