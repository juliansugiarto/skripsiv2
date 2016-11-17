# Filter for front
module Bold
  class ContestFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        sort_column = arg[:sort_by] || 'created_at'
        sort_direction = %w[asc desc].include?(arg[:direction]) ? arg[:direction] : 'desc'
        contests = Contest.where(build.initial_query(arg)).order(sort_column + ' ' + sort_direction)
        # Run more filters

        if arg[:quick_search].present?
          contests = build.quick_search(arg)
          contests = contests.where(build.initial_query(arg)).order(sort_column + ' ' + sort_direction)
        end

        if arg[:spesific_search].present?
          contests = build.spesific_search(contests, arg)
          contests = contests.where(build.initial_query(arg)).order(sort_column + ' ' + sort_direction)
        end

        return build.filter(arg, contests)

      end

    end


    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, contests)
      total_contests = 0
      begin

        if arg[:index_by].present?
          case arg[:index_by]
          when 'contest_holder'
            contest_holder = Member.find(arg[:ch_id])
            raise if contest_holder.nil?
            contests = Contest.where(owner: contest_holder)
          else

          end
        end

        total_contests = contests.count
        if contests.kind_of?(Array)
          contests = Kaminari.paginate_array(contests).page(arg[:page]).per(arg[:per])
        else
          contests = contests.page(arg[:page]).per(arg[:per])
        end

      rescue
        contests = []
        total_contests = 0
      end

      return contests, total_contests
    end

    def quick_search(arg)
      # for quick search by contest Title, Category, Package, Status, Owner
      if arg[:quick_search].present?
        if arg[:quick_search].start_with?('status:=')
          status = ContestStatus.where(cname: Regexp.new(arg[:quick_search].split('status:=')[1].strip.downcase.squish.gsub( /\s/, '_' )))
          contests = Contest.where(:status_id.in => status.pluck(:id))
        elsif arg[:quick_search].start_with?('code:=')
          contest_ids = ContestInvoice.where(unique_code: arg[:quick_search].split('code:=')[1]).pluck(:contest_id)
          contests = Contest.where(:id.in => contest_ids)
        else
          contests_response = Contest.search(query: {
            query_string: {
              query: '*'+arg[:quick_search]+'*',
              fields: ["title", "package.name", "category.name", "owner.username", "status.name"],
              default_operator: "AND"
            }
          })

          contests = contests_response.per(contests_response.results.total).records
        end
      end

      return contests
    end


    def spesific_search(contests, arg)
      hash = JSON.parse arg[:spesific_search]
      if hash["target"].present? && hash["query"].present?
        regexp = Regexp.new(hash["query"], true)
        case hash["target"]
        when "status"
          status = ContestStatus.where(cname: regexp)
          contests = contests.where(:status_id.in => status.pluck(:id))
        when "unique_code"
          contest_ids = ContestInvoice.where(unique_code: hash["query"]).pluck(:contest_id)
          contests = contests.where(:id.in => contest_ids)
        when "contest_holder"
          member_ids = Member.where(username: regexp).pluck(:id)
          contests = contests.where(:owner.in => member_ids)
        when "title"
          contests = contests.where(title: regexp)
        when "package"
          package_ids = Package.where(name: regexp).pluck(:id)
          contests = contests.where(:package_id.in => package_ids) if package_ids.present?
        when "category"
          category = Category.where(name: regexp)
          #try searching for package with category if category exists in first place
          if category.present?
            package = Package.where(:category_id.in => category.pluck(:id))
            contests = contests.any_of(:package_id.in => package.pluck(:id), :category_id.in => category.pluck(:id))
          else
            package = Package.where(name: regexp)
            contests = contests.where(:package_id.in => package.pluck(:id)) if package.present?
          end
        end
      end
      return contests
    end

    # Boost query, anything can filter first goes here
    def initial_query(arg)
      query = Hash.new
      query[:status] = ContestStatus.find_by(cname: arg[:status]) if arg[:status].present?
      if arg[:from].present? and arg[:to].present?
        from = Time.parse(arg[:from])
        to = Time.parse(arg[:to]).end_of_day
        query[:created_at] = from..to
      end

      return query
    end

  end
end
