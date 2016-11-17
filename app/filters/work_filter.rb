# Filter for front
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
          works = Contest.where(build.initial_query(arg)).where(:id.in => arg[:contest_ids])
          if status_ids.present?
            works = works.where(:status_id.in => status_ids)
          end
          works = works.desc(:updated_at)
        # Search for contest_holder, using owner parameters
        else
          works = Contest.where(build.initial_query(arg)).where(owner: arg[:owner])
          if status_ids.present?
            works = works.where(:status_id.in => status_ids)
          end
          works = works.desc(:updated_at)
        end
      # Participation only for designer, search based on participations table
      when "participation"
        works = Contest.where(build.initial_query(arg)).where(:id.in => arg[:contest_ids]).desc(:updated_at)
        if arg[:status_ids].present?
          works = works.where(:status_id.in => arg[:status_ids] )
        end

      when "store"
        works = StorePurchase.any_of({owner: arg[:owner]}, {:item_id.in => arg[:store_item_ids]} ).desc(:updated_at)
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

      # if arg[:status_id].blank?
      #   works = works.where(:status.nin => [ContestStatus.draft, ContestStatus.not_active])
      # end
    rescue
      works = []
      total_works = 0
    end

    return works, total_works
  end

  # Boost query, anything can filter first goes here
  def initial_query(arg)
    query = Hash.new
    query[:status_id] = arg[:status_id] if arg[:status_id].present?
    return query
  end
end
