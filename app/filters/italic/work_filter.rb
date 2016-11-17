# Filter for front
module Italic
  class WorkFilter

    def self.build
      new()
    end

    #                                                                   Class Method
    # ==============================================================================
    class << self

      def search(arg)
        case arg[:type]
        when "contest"
          status_ids = arg[:status_ids]
          # Search for designer, using contest_ids, from participations table
          # Only get contest win by themself
          if arg[:contest_ids].present?
            works = Contest.where(:id.in => arg[:contest_ids])
            if status_ids.present?
              works = works.where(:status_id.in => status_ids)
            end
            works = works.desc(:updated_at)

          # Search for contest_holder, using owner parameters
          else
            works = Contest.where(owner: arg[:owner])
            if status_ids.present?
              works = works.where(:status_id.in => status_ids)
            end
            works = works.desc(:updated_at)
          end
        # Participation only for designer, search based on participations table
        when "participation"
          works = Contest.where(:id.in => arg[:contest_ids]).desc(:updated_at)
          if arg[:status_ids].present?
            works = works.where(:status_id.in => arg[:status_ids] )
          end

        when "store"
          works = StorePurchase.where(:status_id.in => status_ids).desc(:updated_at)
        end
        
        # Run more filters
        return build.filter(arg, works)
      end

    end


    #                                                                Instance Method
    # ==============================================================================
    # All additional/complex filter goes here
    def filter(arg, works)
      total_works = 0
      begin

        total_works = works.count

        if works.kind_of?(Array)
          works = Kaminari.paginate_array(works).page(arg[:page]).per(arg[:per])
        else
          works = works.page(arg[:page]).per(arg[:per])
        end

      rescue
        works = []
        total_works = 0
      end

      return works, total_works
    end

    # Boost query, anything can filter first goes here
    def initial_query(arg)
      query = Hash.new
      return query
    end
  end
end
