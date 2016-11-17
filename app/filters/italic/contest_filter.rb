# Filter for front
module Italic
  class ContestFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        contests = Contest.where(build.initial_query(arg)).where(:testing.nin => [true]).desc(:zn_sort_points)
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

        # Don't display contest not active and draft
        if arg[:status_id].blank?
          contests = contests.where(:status.nin => [ContestStatus.draft, ContestStatus.not_active])
        end

        # Filter features
        if arg[:feature_id].present?
          cfs = ContestFeature.where(:contest_id.in => contests.map(&:id), feature_id: arg[:feature_id])
          contests = contests.where(:id.in => cfs.map(&:contest_id))
        end

        # Filter services
        if arg[:guarantee]
          contests = contests.where(guarantee: true)
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
      query[:category_id] = arg[:category_id] if arg[:category_id].present?
      query[:status_id] = arg[:status_id] if arg[:status_id].present?
      query[:industry_id] = arg[:industry_id] if arg[:industry_id].present?
      query[:title] = /#{Regexp.escape(arg[:title])}/i if arg[:title].present?
      query[:owner] = Member.find_by(id: arg[:owner_id]) if arg[:owner_id].present?
      return query
    end
  end
end
