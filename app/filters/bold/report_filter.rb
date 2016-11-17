# Filter for front
module Bold
  class ReportFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        contests = Contest.where(build.initial_query(arg)).desc(:updated_at)
        # Run more filters
        return build.filter(arg, contests)
      end

    end


    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, contests)
      total_contests = 0
      begin
        # for quick search by contest Title, Category, Package, Status, Owner
        if arg[:quick_search].present?
          #parse the search query
          arg[:quick_search].split('@').each do |q|
            # try searching for category

            regexp = Regexp.new(q, true)

            #try searching for title
            if (!is_req_match(['Category','Package','Status'],regexp) && q!='paid' && q!='unpaid')
              contests = contests.where(title: regexp)
            end

            # #try searching for contest invoice status
            contest_invoice = ContestInvoice.where(status: InvoiceStatus.find_by(cname: q.strip))
            contests = contests.where(:id.in => contest_invoice.pluck(:contest_id)) if contest_invoice.present?

            category = Category.where(name: regexp)
            #try searching for package with category if category exists in first place
            if category.present?
              package = Package.where(:category_id.in => category.pluck(:id))
              contests = contests.any_of(:package_id.in => package.pluck(:id), :category_id.in => category.pluck(:id))
            else
              package = Package.where(name: regexp)
              contests = contests.where(:package_id.in => package.pluck(:id)) if package.present?
            end
            #try searching for contest status
            status = Status.where(name: regexp)
            contests = contests.where(:status_id.in => status.pluck(:id)) if status.present?

            #try searching for contest owner
            owner = Member.where(name: regexp, email: regexp, username: regexp)
            if (owner.present? && !is_req_match(['Category','Package','Status'],regexp) && q!='paid' && q!='unpaid')
              contests_cache = contests
              contests = contests.where(:owner_id.in => owner.pluck(:id))
              #if there is a user but no one have the contest use cache instead
              contests = contests_cache if contests.empty?
            end
            #but if there is special req for search by username do this instead
            if q.start_with?('un:=')
              owner = Member.where(username: Regexp.new(q.split('un:=')[1].strip))
              contests = Contest.where(:owner_id.in => owner.pluck(:id))
            end
          end
        end

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

    # Boost query, anything can filter first goes here
    def initial_query(arg)
      query = Hash.new

      if arg[:from].present? and arg[:to].present?
        from = Time.parse(arg[:from])
        to = Time.parse(arg[:to]).end_of_day
        query[:created_at] = from..to
      end

      return query
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
